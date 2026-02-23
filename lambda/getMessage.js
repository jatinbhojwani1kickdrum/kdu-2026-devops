const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, ScanCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const ddb = DynamoDBDocumentClient.from(client);

exports.handler = async () => {
  try {
    const tableName = process.env.TABLE_NAME;

    const resp = await ddb.send(new ScanCommand({ TableName: tableName }));
    const items = resp.Items || [];

    // newest first (createdAt is a number/string timestamp)
    items.sort((a, b) => Number(b.createdAt || 0) - Number(a.createdAt || 0));

    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: JSON.stringify(items),
    };
  } catch (err) {
    return {
      statusCode: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: JSON.stringify({ error: err?.message || "Unknown error" }),
    };
  }
};