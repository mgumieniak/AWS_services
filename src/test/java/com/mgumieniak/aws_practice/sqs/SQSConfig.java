package com.mgumieniak.aws_practice.sqs;

import lombok.val;
import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider;
import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sts.StsClient;
import software.amazon.awssdk.services.sts.auth.StsAssumeRoleCredentialsProvider;
import software.amazon.awssdk.services.sts.model.AssumeRoleRequest;

class SQSConfig {

    public static String ACCOUNT_NB = "056206897674";
    public static String USER = "webapp_client";
    public static String ROLE = "webapp_client_role";
    public static String REGION = "eu-west-1";
    public static String SQS_NAME = "sqs_mgumieniak";
    public static String SQS_URL = "https://sqs." + REGION + ".amazonaws.com/" + ACCOUNT_NB + "/" + SQS_NAME;
    public static String ROLE_ARN = "arn:aws:iam::" + ACCOUNT_NB + ":role/" + ROLE;
    public static int TMP_CRED_EXP_IN_SEC = 1500;

    private static StsClient createStsClient() {
        return StsClient.builder()
                .region(Region.of(REGION))
                .credentialsProvider(ProfileCredentialsProvider.create(USER))
                .build();
    }

    private static StsAssumeRoleCredentialsProvider createStsAssumeRoleCredentialsProvider(StsClient stsClient) {
        val roleRequest = AssumeRoleRequest.builder()
                .roleArn(ROLE_ARN)
                .roleSessionName(ROLE)
                .durationSeconds(TMP_CRED_EXP_IN_SEC)
                .build();

        return StsAssumeRoleCredentialsProvider.builder()
                .stsClient(stsClient)
                .refreshRequest(roleRequest)
                .build();
    }

    static SqsClient createSqsClient() {
        val credentialsProvider = createStsAssumeRoleCredentialsProvider(createStsClient());

        return SqsClient.builder()
                .credentialsProvider(credentialsProvider)
                .region(Region.of(REGION))
                .build();
    }
}
