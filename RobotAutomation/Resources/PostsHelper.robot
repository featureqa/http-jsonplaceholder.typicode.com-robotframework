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
    ${envVal}=  get_environment
    ${baseurl}=  get_global_variables  ${envVal}    base_url
    ${invalidinituserid}=  get_expected_value  TestData.json  users  InvalidInitial
    ${invalidfinaluserid}=  get_expected_value  TestData.json  users  InvalidFinal
    ${response}=   INITIATE GET REQUEST  Get_Single_Post  ${baseurl}  /users/${invalidinituserid}/posts
    Validate Json    Empty.schema.json    ${response.json()}
    ${response}=   INITIATE GET REQUEST  Get_Single_Post  ${baseurl}  /users/${invalidfinaluserid}/posts
    Validate Json    Empty.schema.json    ${response.json()}
    
VALIDATE POST COUNT BY USER ID
    ${validinituserid}=  get_expected_value  TestData.json  users  validInitial
    ${validfinaluserid}=  get_expected_value  TestData.json  users  validFinal
    ${validinitcount}=  get_expected_value  TestData.json  users  validInitCount
    ${validfinalcount}=  get_expected_value  TestData.json  users  validFinalCount
    ${envVal}=  get_environment
    ${baseurl}=  get_global_variables  ${envVal}    base_url
    ${response}=  INITIATE GET REQUEST  Get_Single_Post  ${baseurl}  /users/${validinituserid}/posts 
    ${postcount}=  ITERATE RESPONSE COUNT  ${response}   
    Should Be Equal As Strings    ${postcount}    ${validinitcount}
    ${response}=  INITIATE GET REQUEST  Get_Single_Post  ${baseurl}  /users/${validfinaluserid}/posts 
    ${postcount}=  ITERATE RESPONSE COUNT  ${response}   
    Should Be Equal As Strings    ${postcount}    ${validfinalcount}

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
    ${validinitpostid}=  get_expected_value  TestData.json  posts  validInitial
    ${validinitpostcount}=  get_expected_value  TestData.json  posts  validInitCount
    ${validfinalpostid}=  get_expected_value  TestData.json  posts  validFinal
    ${validfinalpostcount}=  get_expected_value  TestData.json  posts  validFinalCount
    ${envVal}=  get_environment
    ${baseurl}=  get_global_variables  ${envVal}    base_url
    ${response}=  INITIATE GET REQUEST  Get_Single_Post  ${base_url}  /posts/${validinitpostid}
    VALIDATE RESPONSE SCHEMA  ${response}  Single
    VALIDATE STATUS CODE  200  ${response.status_code}
    VALIDATE SINGLE RESPONSE ID  ${response}  ${validinitpostid}
    ${response}=  INITIATE GET REQUEST  Get_Single_Post  ${base_url}  /posts/${validfinalpostid}
    VALIDATE RESPONSE SCHEMA  ${response}  Single
    VALIDATE STATUS CODE  200  ${response.status_code}
    VALIDATE SINGLE RESPONSE ID  ${response}  ${validfinalpostid}

VALIDATE POST BY INVALID POST ID
    ${invalidinitpostid}=  get_expected_value  TestData.json  posts  InvalidInitial
    ${invalidfinalpostid}=  get_expected_value  TestData.json  posts  InvalidFinal
    ${envVal}=  get_environment
    ${baseurl}=  get_global_variables  ${envVal}    base_url
    ${response}=   Run Keyword And Expect Error  *  INITIATE GET REQUEST  Get_Single_Post  ${baseurl}  /posts/${invalidinitpostid}
    should contain  ${response}  404  
    ${response}=   Run Keyword And Expect Error  *  INITIATE GET REQUEST  Get_Single_Post  ${baseurl}  /posts/${invalidfinalpostid}
    should contain  ${response}  404
    ${randomstr}=  GET RANDOM STRING
    ${response}=   Run Keyword And Expect Error  *  INITIATE GET REQUEST  Get_Single_Post  ${baseurl}  /posts/${randomstr}
    should contain  ${response}  404


