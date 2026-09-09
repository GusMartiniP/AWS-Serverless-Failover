#!/usr/bin/env bash
set -e

STACK_NAME="wizard-resilience"
REGION="us-east-1"

echo "=== 1. Coletando Buckets da Stack ==="
PRIMARY_BUCKET=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" --query "Stacks[0].Outputs[?OutputKey=='BucketPrimario'].OutputValue" --output text 2>/dev/null || true)
REPLICA_BUCKET=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" --query "Stacks[0].Outputs[?OutputKey=='BucketReplica'].OutputValue" --output text 2>/dev/null || true)

clean_bucket() {
  local bucket=$1
  if [ -z "$bucket" ] || [ "$bucket" = "None" ]; then
    return 0
  fi

  echo "Verificando bucket: $bucket..."

  # 1. Deleta versoes existentes (apenas se houver itens)
  local versions
  versions=$(aws s3api list-object-versions --bucket "$bucket" --query "Versions[].{Key:Key,VersionId:VersionId}" --output json 2>/dev/null || true)
  if [ "$versions" != "null" ] && [ "$versions" != "[]" ] && [ -n "$versions" ]; then
    echo "Purgando versoes ativas e antigas de $bucket..."
    aws s3api delete-objects --bucket "$bucket" --delete "{\"Objects\": $versions, \"Quiet\": true}" > /dev/null
  fi

  # 2. Deleta Delete Markers (apenas se houver marcadores)
  local markers
  markers=$(aws s3api list-object-versions --bucket "$bucket" --query "DeleteMarkers[].{Key:Key,VersionId:VersionId}" --output json 2>/dev/null || true)
  if [ "$markers" != "null" ] && [ "$markers" != "[]" ] && [ -n "$markers" ]; then
    echo "Purgando marcadores de exclusao de $bucket..."
    aws s3api delete-objects --bucket "$bucket" --delete "{\"Objects\": $markers, \"Quiet\": true}" > /dev/null
  fi
}

clean_bucket "$PRIMARY_BUCKET"
clean_bucket "$REPLICA_BUCKET"

echo "=== 2. Solicitando Exclusao da Stack ==="
aws cloudformation delete-stack --stack-name "$STACK_NAME" --region "$REGION"

echo "Aguardando exclusao completa dos recursos..."
aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" --region "$REGION"

echo "Infraestrutura removida com sucesso!"
