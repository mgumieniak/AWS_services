package com.mgumieniak.aws_practice.sqs_fifo;

import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import lombok.val;
import org.junit.jupiter.api.Test;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageRequest;
import software.amazon.awssdk.services.sqs.model.SendMessageBatchRequest;
import software.amazon.awssdk.services.sqs.model.SendMessageBatchRequestEntry;

import static com.mgumieniak.aws_practice.sqs_fifo.SQSConfig.SQS_FIFO_URL;
import static com.mgumieniak.aws_practice.sqs_fifo.SQSConfig.createSqsClient;


@Slf4j
class SQSFifoTest {

    private final SqsClient sqsClient = createSqsClient();

    @Test
    @SneakyThrows
    void fifoDeduplicates() {
        val messages1 = SendMessageBatchRequest.builder()
                .queueUrl(SQS_FIFO_URL)
                .entries(
                        // Deduplication based on body hash
                        message("1", "g1", null, "User deleted!"),
                        // Deduplication based on deduplicationId (hash is ignored)
                        message("3", "g1", "dedId_1", "User deleted!")
                )
                .build();
        sqsClient.sendMessageBatch(messages1);

        Thread.sleep(60000);

        val messages2 = SendMessageBatchRequest.builder()
                .queueUrl(SQS_FIFO_URL)
                .entries(
                        // Deduplication based on body hash
                        message("2", "g1", null, "User deleted!"),
                        // Deduplication based on deduplicationId (hash is ignored)
                        message("4", "g1", "dedId_1", "User deleted!")
                )
                .build();
        sqsClient.sendMessageBatch(messages2);

        // Receive messages
        val receiveMessageRequest = ReceiveMessageRequest.builder()
                .queueUrl(SQS_FIFO_URL)
                .maxNumberOfMessages(10)
                .attributeNamesWithStrings("MessageDeduplicationId")
                .build();
        val returnedMessages = sqsClient.receiveMessage(receiveMessageRequest);

        returnedMessages.messages().forEach(msg -> log.info(msg.toString()));

        // Delete processed messages if exists
//        if(!returnedMessages.messages().isEmpty()){
//            val deleteBatchEntries = returnedMessages.messages().stream()
//                    .map(msg -> DeleteMessageBatchRequestEntry.builder().id(msg.messageId()).build())
//                    .toList();
//            sqsClient.deleteMessageBatch(
//                    DeleteMessageBatchRequest.builder().queueUrl(SQS_FIFO_URL).entries(deleteBatchEntries).build()
//            );
//
//            assertThat(returnedMessages.messages().stream()
//                    .map(msg -> msg.attributesAsStrings().get("MessageDeduplicationId")).toList())
//                    .containsOnlyOnce("1a234d4664ee809610338597a65c513dfd4d05f0551bcfaff0c4b22bdc53915f", "dedId_1");
//        }
    }

    private SendMessageBatchRequestEntry message(String id, String groupId, String deduplicationId, String body) {
        return SendMessageBatchRequestEntry.builder()
                .id(id)
                .messageGroupId(groupId)
                .messageDeduplicationId(deduplicationId)
                .messageBody(body)
                .build();
    }

}
