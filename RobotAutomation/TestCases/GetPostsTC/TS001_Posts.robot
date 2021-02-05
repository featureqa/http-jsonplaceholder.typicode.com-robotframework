*** Settings ***
Resource  ../../Resources/PostsHelper.robot
Test Setup  ENVIRONMENT SETUP

*** Test Cases ***
TC001 VALIDATE GET ALL POSTS ENDPOINT
    [Documentation]  Validate Get All Posts REST endpoint status code, response size and user post count
    [Tags]  Positive
    ${response}=  INITIATE GET REQUEST  Get_All_Posts  ${base_url}  /posts
    VALIDATE RESPONSE SCHEMA  ${response}  All
    VALIDATE STATUS CODE  200  ${response.status_code}
    VALIDATE RESPONSE SIZE  ${allpostcnt}  ${response}

TC002 VALIDATE POST COUNT BY USER ID - VALID BOUNDARY ANALYSIS
    [Documentation]  Validate Expected Post Count by User Id for valid Boundary Analysis
    [Tags]  Positive Boundary
    Set Test Documentation    Valid Id Boundary Values: 1,10
    # Test Data is present in Fixtures/TestData.json
    VALIDATE POST COUNT BY USER ID

TC003 VALIDATE EMPTY POST COUNT BY INVALID USER ID - INVALID BOUNDARY ANALYSIS
    [Documentation]  Validate Edge Cases for Getting post by invalid user id for invalid Boundary Analysis
    [Tags]  Negative Boundary
    Set Test Documentation    Invalid Id Boundary Values: 0,11
    VALIDATE POST COUNT BY INVALID USER ID

TC004 VALIDATE GET POST BY POST ID - VALID BOUNDARY ANALYSIS
    [Documentation]  Validate Response for Getting post by passing single post id
    [Tags]  Positive Smoke
    Set Test Documentation  Valid Post Id Boundary Values: 1,100
    VALIDATE POST BY VALID POST ID

TC005 VALIDATE GET POST BY POST ID - INVALID BOUNDARY ANALYSIS
    [Documentation]  Validate Edge cases for Getting post by single post id for invalid Boundary Analysis
    [Tags]  Negative Smoke
    Set Test Documentation    Invalid Post Id Boundary Values: 0,101
    VALIDATE POST BY INVALID POST ID

TC006 COMPARE USER ID FILTERED ALL POSTS RESPONSE TO GET POST BY USER ID
    [Documentation]  Validate the response when filtered with user id matches response when requested with specific user id
    Set Test Documentation    Todo

TC007 COMPARE POST ID FILTERED POST ENDPOINT RESPONSE TO GET POST BY POST ID URI RESPONSE
    [Documentation]  Validate the response from /posts?id={num} matches response from /posts/{num}
    Set Test Documentation    Todo

TC008 VALIDATE GET POST BY POST ID FOR ALL POST ID
    [Documentation]  Validate Response for Getting post by passing single post id
    [Tags]  Positive Extensive
    # Validating response for each unique post id
    ${allpostnum}=  Convert To Integer    ${allpostcnt}
    FOR  ${postid}  IN RANGE  1  ${allpostnum+1}
        ${response}=  INITIATE GET REQUEST  Get_Single_Post  ${base_url}  /posts/${postid}
        VALIDATE RESPONSE SCHEMA  ${response}  Single
        VALIDATE STATUS CODE  200  ${response.status_code}
        VALIDATE SINGLE RESPONSE ID  ${response}  ${postid}
    END
 

*** Keywords ***
ENVIRONMENT SETUP
    ${url}=  GET ENVIRONMENT TYPE  base_url
    ${allpostcount}=  GET TEMPLATE VALUE  TestData.json  allposts  postcount
    Set Suite Variable    ${base_url}  ${url}   
    Set Suite Variable    ${templatefile}  TestData.json
    Set Suite Variable    ${allpostcnt}  ${allpostcount}



    
    
