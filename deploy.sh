#!/usr/bin/env bash
set -e

STACK_NAME="wizard-resilience"
REGION="us-east-1"
ALERT_EMAIL="seu-email@wizard.com.br"
ENVIRONMENT="prod"

echo "=== 1. Provisionando a Infraestrutura via CloudFormation (us-east-1) ==="
aws cloudformation deploy \
  --template-file template.yaml \
  --stack-name "$STACK_NAME" \
  --parameter-overrides AlertEmail="$ALERT_EMAIL" Environment="$ENVIRONMENT" \
  --capabilities CAPABILITY_NAMED_IAM \
  --region "$REGION"

echo "=== 2. Coletando Saídas da Stack ==="
PRIMARY_BUCKET=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --query "Stacks[0].Outputs[?OutputKey=='BucketPrimario'].OutputValue" \
  --output text)

API_ENDPOINT=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --query "Stacks[0].Outputs[?OutputKey=='ApiLeadsEndpoint'].OutputValue" \
  --output text)

SITE_URL=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --query "Stacks[0].Outputs[?OutputKey=='SiteUrl'].OutputValue" \
  --output text)

DISTRIBUTION_ID=$(aws cloudformation describe-stack-resource \
  --stack-name "$STACK_NAME" \
  --logical-resource-id CloudFrontDistribution \
  --region "$REGION" \
  --query "StackResourceDetail.PhysicalResourceId" \
  --output text)

echo "Bucket Alvo:      $PRIMARY_BUCKET"
echo "API Endpoint:     $API_ENDPOINT"
echo "Distribution ID:  $DISTRIBUTION_ID"

echo "=== 3. Injetando API URL e Sincronizando index.html com o S3 ==="
# Aceita tanto o placeholder {{API_ENDPOINT}} quanto URLs prévias de API Gateway
sed -E "s|(\{\{API_ENDPOINT\}\}|https://[a-zA-Z0-9]+\.execute-api\.[a-zA-Z0-9-]+\.amazonaws\.com/prod/leads)|$API_ENDPOINT|g" index.html > /tmp/index.html

aws s3 cp /tmp/index.html "s3://${PRIMARY_BUCKET}/index.html" \
  --content-type "text/html; charset=utf-8" \
  --cache-control "max-age=60, s-maxage=3600" \
  --region "$REGION"

echo "=== 4. Invalidando Cache de Borda no CloudFront ==="
INVALIDATION_ID=$(aws cloudfront create-invalidation \
  --distribution-id "$DISTRIBUTION_ID" \
  --paths "/index.html" "/" "/*" \
  --query "Invalidation.Id" \
  --output text)

echo "Invalidação iniciada: $INVALIDATION_ID"

rm -f /tmp/index.html

echo ""
echo "===================================================="
echo "✅ Deploy executado com sucesso!"
echo "🌐 URL Pública (CloudFront): $SITE_URL"
echo "📡 Endpoint da API Gateway:  $API_ENDPOINT"
echo "📦 Bucket Primário:          $PRIMARY_BUCKET"
echo "===================================================="