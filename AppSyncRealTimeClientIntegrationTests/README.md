## AppSync RealTime GraphQL Service 

The following steps demonstrate how to set up a GraphQL endpoint with AppSync. The auth configured will be API key. The set up is used to run the integration tests.


### Set-up

1. `amplify-init`

2. `amplify add api`

    ```perl
    ? Please select from one of the below mentioned services: `GraphQL`
    ? Provide API name: `<APIName>`
    ? Choose the default authorization type for the API `API key`
    ? Enter a description for the API key:
    ? After how many days from now the API key should expire (1-365): `365`
    ? Do you want to configure advanced settings for the GraphQL API `No, I am done`
    ? Do you have an annotated GraphQL schema? `Yes`
    ? Provide your schema file path: `Support/schema.graphql`
    ```

3.  `amplify push`

    ```perl
    ? Do you want to generate code for your newly created GraphQL API `No`
    ```

4. Copy `amplifyconfiguration.json`  over to this integration test project. This file is already set up to be copied to the HostApp bundle and loaded when the test is run.
