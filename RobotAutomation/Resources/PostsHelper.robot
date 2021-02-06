*** Settings ***
Library  RequestsLibrary
Library  JSONLibrary
Library  Collections
Library  ../UserDefinedKeywords/FixtureLoader.py
Library  JSONSchemaLibrary  ../../Fixtures/JsonTemplates
Library  String
Library    OperatingSystem

*** Keywords ***
INITIATE GET REQUEST
    [Arguments]  ${session_name}  ${url}  ${endpoint}
    Create Session  ${session_name}  ${url}
    ${response}=  Get On Session  ${session_name}  ${endpoint}
    [Return]  ${response}

GET ENVIRONMENT TYPE
    [Arguments]  ${value}
    ${envVal}=  get_environment
    ${result}=  get_global_variables  ${envVal}    ${value}
    [Return]  ${result}

GET TEMPLATE VALUE
    [Arguments]  ${templatefile}  ${key}  ${value}
    ${tempvalue}=  get_expected_value  ${templatefile}  ${key}  ${value}
    [Return]  ${tempvalue}

VALIDATE STATUS CODE
    [Arguments]  ${value}  ${statuscode}
    Should Be Equal As Strings  ${statuscode}    ${value}

VALIDATE RESPONSE SIZE
    [Arguments]  ${value}  ${response}
    @{idlist}  Create List
    FOR   ${item}  IN  @{response.json()}
        Append To List    ${idlist}  ${item['id']}
    END
    ${cnt}=  Get length  ${idlist}
    Should Be Equal As Strings    ${cnt}    ${value}  
    @{idlist}  Create List

VALIDATE SINGLE RESPONSE ID
    [Arguments]  ${response}  ${postidrequest}
    @{idvalue}  Create List
    ${idvalue}=  Get Value From Json    ${response.json()}    id
    ${responseid}=  GET FROM LIST  ${idvalue}  0
    Should Be Equal As Strings    ${responseid}    ${postidrequest}
    @{idvalue}  Create List


VALIDATE USER POST COUNT
    [Arguments]  ${id}  ${segmentsize}  ${response}
    @{useridlist}  Create List
    FOR   ${item}  IN  @{response.json()}
        Run Keyword If    "${item['userId']}" == "${id}"  Append To List  ${useridlist}  ${item['id']}
    END
    ${cnt}=  Get Length  ${useridlist}
    Should Be Equal As Strings    ${cnt}    ${segmentsize}
    @{useridlist}  Create List

VALIDATE RESPONSE SCHEMA
    [Arguments]  ${response}  ${responsetype}
   Run Keyword If    '${responsetype}' == 'All'
   ...    Validate Json    GET_Posts.schema.json    ${response.json()}
   ...  ELSE IF    '${responsetype}' == 'Single'
   ...    Validate Json    GET_Single_Posts.schema.json    ${response.json()}
   ...  ELSE IF    '${responsetype}' == 'Empty'
   ...    Validate Json    Empty.schema.json    ${response.json()}

GET RANDOM STRING
    ${randompostid}  Generate Random String  5  [LETTERS]
    [Return]  ${randompostid}

VALIDATE POST COUNT BY INVALID USER ID
    [Arguments]  ${userid}
    ${envVal}=  get_environment
    ${baseurl}=  get_global_variables  ${envVal}    base_url
    ${response}=   INITIATE GET REQUEST  Get_Single_Post  ${baseurl}  /users/${userid}/posts
    Validate Json    Empty.schema.json    ${response.json()}
    
VALIDATE POST COUNT BY USER ID
    [Arguments]  ${userid}  ${exppostcount}
    ${envVal}=  get_environment
    ${baseurl}=  get_global_variables  ${envVal}    base_url
    ${response}=  INITIATE GET REQUEST  Get_Single_Post  ${baseurl}  /users/${userid}/posts 
    ${postcount}=  ITERATE RESPONSE COUNT  ${response}   
    Should Be Equal As Strings    ${postcount}    ${exppostcount}

ITERATE RESPONSE COUNT
    [Arguments]  ${response}
    @{postresponselist}  Create List
    FOR  ${data}  IN  @{response.json()}
        Append To List    ${postresponselist}  ${data['id']}
    END
    ${cnt}=  get length  ${postresponselist}
    @{postresponselist}  Create List
    [Return]  ${cnt}

VALIDATE POST BY VALID POST ID
    [Arguments]  ${postid}
    ${envVal}=  get_environment
    ${baseurl}=  get_global_variables  ${envVal}    base_url
    ${response}=  INITIATE GET REQUEST  Get_Single_Post  ${base_url}  /posts/${postid}
    VALIDATE RESPONSE SCHEMA  ${response}  Single
    VALIDATE STATUS CODE  200  ${response.status_code}
    VALIDATE SINGLE RESPONSE ID  ${response}  ${postid}
   
VALIDATE POST BY INVALID POST ID
    [Arguments]  ${postid}
    ${envVal}=  get_environment
    ${baseurl}=  get_global_variables  ${envVal}    base_url
    ${response}=   Run Keyword And Expect Error  *  INITIATE GET REQUEST  Get_Single_Post  ${baseurl}  /posts/${postid}
    should contain  ${response}  404  
    ${randomstr}=  GET RANDOM STRING
    ${response}=   Run Keyword And Expect Error  *  INITIATE GET REQUEST  Get_Single_Post  ${baseurl}  /posts/${randomstr}
    should contain  ${response}  404

VALIDATE FILTERED POST RESPONSE MATCHES USER ID URI POST RESPONSE
    [Arguments]  ${userid}
    ${envVal}=  get_environment
    ${baseurl}=  get_global_variables  ${envVal}    base_url
    ${response}=  INITIATE GET REQUEST  Get_Single_Post  ${baseurl}  /users/${userid}/posts
    @{uriidlist}  Create List
    @{filteridlist}  Create List
    @{urititlelist}  Create List
    @{filtertitlelist}  Create List
    @{uribodylist}  Create List
    @{filterbodylist}  Create List
    FOR   ${item}  IN  @{response.json()}
        Append To List    ${uriidlist}  ${item['id']}
        Append To List    ${urititlelist}  ${item['title']}
        Append To List    ${urititlelist}  ${item['body']}
    END
    ${response}=  INITIATE GET REQUEST  Get_All_Post  ${baseurl}  /posts
    FOR   ${item}  IN  @{response.json()}
        Run Keyword If    "${item['userId']}" == "${userid}"  Append To List  ${filteridlist}  ${item['id']}
        Run Keyword If    "${item['userId']}" == "${userid}"  Append To List  ${filtertitlelist}  ${item['title']}
        Run Keyword If    "${item['userId']}" == "${userid}"  Append To List  ${filtertitlelist}  ${item['body']}
    END
    Lists Should Be Equal    ${uriidlist}    ${filteridlist}
    Lists Should Be Equal    ${urititlelist}    ${filtertitlelist}
    Lists Should Be Equal    ${uribodylist}    ${filterbodylist}
    @{uriidlist}  Create List
    @{filteridlist}  Create List
    @{urititlelist}  Create List
    @{filtertitlelist}  Create List
    @{uribodylist}  Create List
    @{filterbodylist}  Create List

VALIDATE FILTERED POST URL RESPONSE MATCHES POST ID URI POST RESPONSE
    [Arguments]  ${postid}  ${negativepos}
    @{post_list}=  Split String    ${postid}
    ${cnt}=  Get Length    ${post_list}
    log to console  ${cnt}
    ${envVal}=  get_environment
    ${baseurl}=  get_global_variables  ${envVal}    base_url
    Create Session  GET_With_Params  ${baseurl}
    ${responseparam}=  Run Keyword If    ${cnt} == 1
    ...    Get On Session  GET_With_Params  url=/posts?id=${post_list}[0]
    ...  ELSE IF    ${cnt} == 2
    ...    Get On Session  GET_With_Params  url=/posts?id=${post_list}[0]&id=${post_list}[1] 
    @{uriidlist}  Create List
    @{filteridlist}  Create List
    @{urititlelist}  Create List
    @{filtertitlelist}  Create List
    @{uribodylist}  Create List
    @{filterbodylist}  Create List
    FOR   ${item}  IN  @{responseparam.json()}
        Append To List    ${uriidlist}  ${item['id']}
        Append To List    ${urititlelist}  ${item['title']}
        Append To List    ${uribodylist}  ${item['body']}
    END
    Create Session  GET_With_URI  ${baseurl}
    ${response}=  Run Keyword If    ${negativepos} == 0
    ...    Get On Session  GET_With_URI  /posts/${post_list}[0]
    ...  ELSE
    ...    Get On Session  GET_With_URI  /posts/${post_list}[1]
    ${filteridlist}=  get value from json  ${response.json()}  id
    ${filtertitlelist}=  get value from json  ${response.json()}  title
    ${filterbodylist}=  get value from json  ${response.json()}  body
    Lists Should Be Equal    ${filteridlist}    ${uriidlist}
    Lists Should Be Equal    ${filtertitlelist}    ${urititlelist}
    Lists Should Be Equal    ${filterbodylist}    ${uribodylist}
    @{uriidlist}  Create List
    @{filteridlist}  Create List
    @{urititlelist}  Create List
    @{filtertitlelist}  Create List
    @{uribodylist}  Create List
    @{filterbodylist}  Create List
    @{post_list}  Create List