*** Settings ***
Resource  ../../Resources/APIHelper.robot
Test Setup  ENVIRONMENT SETUP

*** Test Cases ***
TC001 VALIDATE GET ALL POSTS ENDPOINT
    [Documentation]  Validate Get All Posts REST endpoint status code, response size and segmentation
    [Tags]  Positive
    ${response}=  INITIATE GET REQUEST  Get_All_Posts  ${base_url}  /posts
    VALIDATE RESPONSE SCHEMA  ${response}  All
    VALIDATE STATUS CODE  200  ${response.status_code}
    VALIDATE RESPONSE SIZE  ${templatefile}    size    allposts    ${response}
    # The below code is to dynamically spot check json response segmentation based on User Id
    VALIDATE RESPONSE SEGMENTATION  ${singleuser}  ${segmentcnt}  ${response}
    
TC002 VALIDATE GET POST BY ID
    [Documentation]  Validate Response for Getting post by passing single post id
    [Tags]  Positive
    # Validating response for each unique post id
    ${allpostnum}=  Convert To Integer    ${allpostcnt}
    FOR  ${i}  IN RANGE  1  ${allpostnum+1}
        ${response}=  INITIATE GET REQUEST  Get_Single_Post  ${base_url}  /posts/${i}
        VALIDATE RESPONSE SCHEMA  ${response}  Single
        VALIDATE STATUS CODE  200  ${response.status_code}
        VALIDATE SINGLE RESPONSE ID  ${response}  ${i}
    END

TC003 VALIDATE GET POST BY INVALID ID
    [Documentation]  Validate Edge cases for Getting post by single post id
    [Tags]  Negative
    # Boundary Conditions
    GET POST BY INVALID ID    0
    GET POST BY INVALID ID    101
    # Random string entry
    ${randompost}=  GET RANDOM STRING
    GET POST BY INVALID ID    ${randompost}  
    
TC004 VALIDATE POST COUNT BY USER ID
    [Documentation]  Validate Expected Post Count by User Id
    [Tags]  Positive
    # Data driven test which uses the expected test data from Fixtures/JsonTemplates/TestData.json file
    VALIDATE POST COUNT BY USER ID 

TC005 GET POST BY INVALID USER ID
    [Documentation]  Validate Edge Cases for Getting post by invalid user id
    [Tags]  Negative
    GET POST BY INVALID USER ID  11
    GET POST BY INVALID USER ID  0

*** Keywords ***
ENVIRONMENT SETUP
    ${url}=  GET ENVIRONMENT TYPE  base_url
    ${allpostcount}=  GET TEMPLATE VALUE  GET_Posts.json  size  allposts
    ${segmentationcount}=  GET TEMPLATE VALUE  GET_Posts.json  user  postcount
    ${singleuserid}=  GET TEMPLATE VALUE  GET_Posts.json  user  id
    Set Suite Variable    ${base_url}  ${url}   
    Set Suite Variable    ${templatefile}  GET_Posts.json
    Set Suite Variable    ${allpostcnt}  ${allpostcount}
    Set Suite Variable    ${segmentcnt}  ${segmentationcount}
    Set Suite Variable    ${singleuser}  ${singleuserid}

    
    
