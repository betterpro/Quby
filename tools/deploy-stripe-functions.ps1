#!/usr/bin/env pwsh
# Deploy Stripe Edge Functions to Supabase.
# Prerequisites: npx supabase login, then link this repo to your project.
#
# Usage:
#   ./tools/deploy-stripe-functions.ps1

$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)

Write-Host "Linking project (skip if already linked)..." -ForegroundColor Cyan
npx supabase link --project-ref tbsuulymqbxzlzzahvgc

Write-Host "`nSet secrets first if you have not already:" -ForegroundColor Yellow
Write-Host "  npx supabase secrets set STRIPE_SECRET_KEY=sk_test_..."
Write-Host "  npx supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_..."

Write-Host "`nDeploying create-payment-intent..." -ForegroundColor Cyan
npx supabase functions deploy create-payment-intent

Write-Host "`nDeploying stripe-webhook..." -ForegroundColor Cyan
npx supabase functions deploy stripe-webhook

Write-Host "`nDone. Webhook URL:" -ForegroundColor Green
Write-Host "  https://tbsuulymqbxzlzzahvgc.supabase.co/functions/v1/stripe-webhook"
