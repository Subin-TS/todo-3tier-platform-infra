import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info("S3 event received: %s", json.dumps(event))

    for record in event.get("Records", []):
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]
        size = record["s3"]["object"].get("size", 0)

        logger.info(
            "S3 Object Created - bucket=%s key=%s size=%s bytes",
            bucket,
            key,
            size,
        )

    return {
        "statusCode": 200,
        "body": json.dumps("S3 event processed successfully"),
    }
