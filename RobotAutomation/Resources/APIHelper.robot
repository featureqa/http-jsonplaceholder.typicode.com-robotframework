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
    [Arguments]  ${templatefile}  ${key}  ${value}  ${response}
    @{idlist}  Create List
    FOR   ${item}  IN  @{response.json()}
        Append To List    ${idlist}  ${item['id']}
    END
    ${cnt}=  Get length  ${idlist}
    ${expectedsize}=  get_expected_value  ${templatefile}  ${key}  ${value}
    Should Be Equal As Strings    ${cnt}    ${expectedsize}  
    @{idlist}  Create List

VALIDATE SINGLE RESPONSE ID
    [Arguments]  ${response}  ${postidrequest}
    @{idvalue}  Create List
    ${idvalue}=  Get Value From Json    ${response.json()}    id
    ${responseid}=  GET FROM LIST  ${idvalue}  0
    Should Be Equal As Strings    ${responseid}    ${postidrequest}
    @{idvalue}  Create List


VALIDATE RESPONSE SEGMENTATION
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

GET POST BY INVALID ID
    [Arguments]  ${postid}
    ${envVal}=  get_environment
    ${baseurl}=  get_global_variables  ${envVal}    base_url
    ${response}=   Run Keyword And Expect Error  *  INITIATE GET REQUEST  Get_Single_Post  ${baseurl}  /posts/${postid}
    should contain  ${response}  404  

GET POST BY INVALID USER ID
    [Arguments]  ${userid}
    ${envVal}=  get_environment
    ${baseurl}=  get_global_variables  ${envVal}    base_url
    ${response}=   INITIATE GET REQUEST  Get_Single_Post  ${baseurl}  /users/${userid}/posts
    Validate Json    Empty.schema.json    ${response.json()}
    
VALIDATE POST COUNT BY USER ID
    ${response_object}=  Get File  ../../Fixtures/JsonTemplates/TestData.json
    ${response_object}=  Evaluate    json.loads("""${response_object}""")  json
    ${envVal}=  get_environment
    ${baseurl}=  get_global_variables  ${envVal}    base_url
    FOR  ${item}  IN  @{response_object}
        ${response}=  INITIATE GET REQUEST  Get_Single_Post  ${baseurl}  /users/${item['userid']}/posts 
        ${postcount}=  ITERATE RESPONSE COUNT  ${response}   
        Should Be Equal As Strings    ${postcount}    ${item['postcount']}
    END

ITERATE RESPONSE COUNT
    [Arguments]  ${response}
    @{postresponselist}  Create List
    FOR  ${data}  IN  @{response.json()}
        Append To List    ${postresponselist}  ${data['id']}
    END
    ${cnt}=  get length  ${postresponselist}
    [Return]  ${cnt}
    


