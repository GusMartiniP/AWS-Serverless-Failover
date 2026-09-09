import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { PutItemCommand } from "@aws-sdk/client-dynamodb";
import { randomUUID } from "crypto";

const client = new DynamoDBClient({});
const TABLE_NAME = "wizard-leads";

// Domínio real do site, servido via CloudFront
const ALLOWED_ORIGIN = "https://d6po1ddgej1q1.cloudfront.net";

function corsHeaders() {
  return {
    "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
  };
}

function isValidEmail(email) {
  return typeof email === "string" && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) && email.length <= 254;
}

export const handler = async (event) => {
  try {
    const body = JSON.parse(event.body || "{}");
    const nome = String(body.nome || "").trim().slice(0, 120);
    const email = String(body.email || "").trim().slice(0, 254);
    const telefone = String(body.telefone || "").trim().slice(0, 20);

    if (!nome || !isValidEmail(email)) {
      return {
        statusCode: 400,
        headers: corsHeaders(),
        body: JSON.stringify({ message: "Dados inválidos." }),
      };
    }

    const leadId = randomUUID();
    await client.send(new PutItemCommand({
      TableName: TABLE_NAME,
      Item: {
        leadId: { S: leadId },
        nome: { S: nome },
        email: { S: email },
        telefone: { S: telefone },
        criadoEm: { S: new Date().toISOString() },
      },
    }));

    return {
      statusCode: 200,
      headers: corsHeaders(),
      body: JSON.stringify({ message: "Lead recebido.", leadId }),
    };
  } catch (err) {
    console.error(err);
    return {
      statusCode: 500,
      headers: corsHeaders(),
      body: JSON.stringify({ message: "Erro interno." }),
    };
  }
};