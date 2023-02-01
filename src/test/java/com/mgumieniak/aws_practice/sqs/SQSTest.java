package com.mgumieniak.aws_practice.sqs;

import com.mgumieniak.aws_practice.InMemoryDB;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import lombok.val;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.SendMessageBatchRequest;
import software.amazon.awssdk.services.sqs.model.SendMessageBatchRequestEntry;
import software.amazon.awssdk.services.sqs.model.SendMessageRequest;

import static com.mgumieniak.aws_practice.sqs.SQSConfig.SQS_URL;
import static com.mgumieniak.aws_practice.sqs.SQSConfig.createSqsClient;

@Slf4j
class SQSTest {

    private final SqsClient sqsClient = createSqsClient();
    private final InMemoryDB<Long, User> usersDb = new InMemoryDB<>();
    private final InMemoryDB<Long, OutboxEvent> outboxEventDb = new InMemoryDB<>();

    @BeforeEach
    void setUp() {
        usersDb.deleteAll();
    }

    @Test
    @SneakyThrows
        // process + produce
    void atMostOnceDelivery() {
        usersDb.save(1L, new User("John"));
        val msg = SendMessageRequest.builder()
                .queueUrl(SQS_URL)
                .messageBody("USER_CREATED")
                .build();
        sqsClient.sendMessage(msg); // request can fail
    }

    @Test
    @SneakyThrows
        // process + produce
    void atLeastOnceDelivery() {
        // Both operation should be in transaction
        usersDb.save(1L, new User("John"));
        outboxEventDb.save(1L, new OutboxEvent("USER_CREATED"));


        // ... in other thread check cycling if there are some events
        val eventsToSend = outboxEventDb.findAll();
        val batchRequestEntries = eventsToSend.stream()
                .map(event -> SendMessageBatchRequestEntry.builder()
                        .messageBody(event.json)
                        .build())
                .toList();
        val batchRequest = SendMessageBatchRequest.builder()
                .queueUrl(SQS_URL)
                .entries(batchRequestEntries)
                .build();
        sqsClient.sendMessageBatch(batchRequest);
        outboxEventDb.deleteAll(); // only after successful batch send, delete from db.
    }

    record User(String name) {
    }

    record OutboxEvent(String json) {
    }
}
