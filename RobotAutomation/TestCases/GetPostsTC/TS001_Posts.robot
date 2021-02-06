*** Settings ***
Resource  ../../Resources/PostsHelper.robot
Test Setup  ENVIRONMENT SETUP

*** Test Cases ***
TC001 VALIDATE GET ALL POSTS ENDPOINT
    [Documentation]  Validate Get All Posts REST endpoint status code, response size and user post count
    [Tags]  Positive  Smoke
    ${response}=  INITIATE GET REQUEST  Get_All_Posts  ${base_url}  /posts
    VALIDATE RESPONSE SCHEMA  ${response}  All
    VALIDATE STATUS CODE  200  ${response.status_code}
    VALIDATE RESPONSE SIZE  ${allpostcnt}  ${response}

TC002 VALIDATE POST COUNT BY USER ID - VALID BOUNDARY ANALYSIS
    [Documentation]  Validate Expected Post Count by User Id for valid Boundary Analysis
    [Tags]  Positive  Smoke
    Set Test Documentation    Valid Id Boundary Keys on TestData.json: users.validInitial, users.validInitCount, users.validFinal, users.validFinalCCount
    # Test Data is present in Fixtures/TestData.json
    VALIDATE POST COUNT BY USER ID  ${userinId}  ${userinCount}
    VALIDATE POST COUNT BY USER ID  ${userfId}  ${userfCount}

TC003 VALIDATE EMPTY POST COUNT BY INVALID USER ID - INVALID BOUNDARY ANALYSIS
    [Documentation]  Validate Edge Cases for Getting post by invalid user id for invalid Boundary Analysis
    [Tags]  Negative  Smoke
    Set Test Documentation    Invalid Id Boundary Keys on TestData.json: users.InvalidInitial, users.InvalidFinal
    VALIDATE POST COUNT BY INVALID USER ID  ${invalidIuserid}
    VALIDATE POST COUNT BY INVALID USER ID  ${invalidFuserid}

TC004 VALIDATE GET POST BY POST ID - VALID BOUNDARY ANALYSIS
    [Documentation]  Validate Response for Getting post by passing single post id
    [Tags]  Positive  Smoke
    Set Test Documentation  Valid Post Id Boundary Values on TestData.json: posts.validInitial, posts.validFinal
    VALIDATE POST BY VALID POST ID  ${postinId}
    VALIDATE POST BY VALID POST ID  ${postfId}

TC005 VALIDATE GET POST BY POST ID - INVALID BOUNDARY ANALYSIS
    [Documentation]  Validate Edge cases for Getting post by single post id for invalid Boundary Analysis
    [Tags]  Negative  Smoke
    Set Test Documentation    Invalid Post Id Boundary Values: posts.InvalidInitial, posts.InvalidFinal
    VALIDATE POST BY INVALID POST ID  ${invalidIpostid}
    VALIDATE POST BY INVALID POST ID  ${invalidFpostid}

TC006 COMPARE USER ID FILTERED ALL POSTS RESPONSE TO GET POST BY USER ID
    [Documentation]  Validate the response when filtered with user id matches response when requested with specific user id
    [Tags]  Positive  Smoke
    Set Test Documentation    Compare Full Response User Id filtering to /users/{userid}/posts
    # VALIDATE FILTERED POST RESPONSE MATCHES USER ID URI POST RESPONSE
    VALIDATE FILTERED POST RESPONSE MATCHES USER ID URI POST RESPONSE  ${userinId}
    VALIDATE FILTERED POST RESPONSE MATCHES USER ID URI POST RESPONSE  ${userfId}

TC007 COMPARE POST ID FILTERED POST ENDPOINT RESPONSE TO GET POST BY POST ID URI RESPONSE
    [Documentation]  Validate the response from /posts?id={num} matches response from /posts/{num}
    [Tags]  Hybrid  Smoke
    Set Test Documentation    Compare /posts parameter filter response to posts/{num}
    VALIDATE FILTERED POST URL RESPONSE MATCHES POST ID URI POST RESPONSE  ${postinId}  0
    VALIDATE FILTERED POST URL RESPONSE MATCHES POST ID URI POST RESPONSE  ${postfId}  0
    VALIDATE FILTERED POST URL RESPONSE MATCHES POST ID URI POST RESPONSE  ${postfId} ${invalidIpostid}  0
    VALIDATE FILTERED POST URL RESPONSE MATCHES POST ID URI POST RESPONSE  ${invalidIpostid} ${postfId}  1
    VALIDATE FILTERED POST URL RESPONSE MATCHES POST ID URI POST RESPONSE  ${postinId} ${invalidFpostid}  0
    VALIDATE FILTERED POST URL RESPONSE MATCHES POST ID URI POST RESPONSE  ${invalidFpostid} ${postinId}  1


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
    ${userinitid}=  GET TEMPLATE VALUE    TestData.json    users    validInitial
    ${userpostinitcount}=  GET TEMPLATE VALUE    TestData.json    users    validInitCount
    ${userfinalid}=  GET TEMPLATE VALUE    TestData.json    users    validFinal
    ${userpostfinalcount}=  GET TEMPLATE VALUE    TestData.json    users    validFinalCount
    ${invaliduserinitid}=  GET TEMPLATE VALUE    TestData.json    users    InvalidInitial
    ${invaliduserfinalid}=  GET TEMPLATE VALUE    TestData.json    users    InvalidFinal
    ${postinitid}=  GET TEMPLATE VALUE    TestData.json    posts    validInitial
    ${postfinalid}=  GET TEMPLATE VALUE    TestData.json    posts    validFinal
    ${invalidpostinitid}=  GET TEMPLATE VALUE    TestData.json    posts    InvalidInitial
    ${invalidpostfinalid}=  GET TEMPLATE VALUE    TestData.json    posts    InvalidFinal
    Set Suite Variable    ${base_url}  ${url}   
    Set Suite Variable    ${templatefile}  TestData.json
    Set Suite Variable    ${allpostcnt}  ${allpostcount}
    Set Suite Variable    ${userinId}  ${userinitid}
    Set Suite Variable    ${userinCount}  ${userpostinitcount}
    Set Suite Variable    ${userfId}  ${userfinalid}
    Set Suite Variable    ${userfCount}  ${userpostfinalcount}
    Set Suite Variable    ${invalidIuserid}  ${invaliduserinitid}
    Set Suite Variable    ${invalidFuserid}  ${invaliduserfinalid}
    Set Suite Variable    ${postinId}  ${postinitid}
    Set Suite Variable    ${postfId}  ${postfinalid}
    Set Suite Variable    ${invalidIpostid}  ${invalidpostinitid}
    Set Suite Variable    ${invalidFpostid}  ${invalidpostfinalid}



    
    
