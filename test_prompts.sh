#!/bin/bash

echo "=========================================="
echo "Claude Yes Test Script"
echo "=========================================="
echo ""

echo "🤖 I'll help you implement this feature."
echo "Continue? 1) Yes 2) No"
read -p "👤 Enter choice: " choice
echo "You chose: $choice"
echo ""

echo "🤖 What is the name of the component?"
read -p "👤 Component name: " name  
echo "Component name: $name"
echo ""

echo "🤖 Which framework would you prefer to use?"
echo "1) React"
echo "2) Vue" 
echo "3) Angular"
read -p "👤 Framework choice: " framework
echo "Framework: $framework"
echo ""

echo "🤖 Implementation complete! Please test the functionality."
echo "Continue? (y/n)"
read -p "👤 Enter choice: " final
echo "Final choice: $final"
echo ""

echo "✅ Test script completed!"
echo "Expected behavior:"
echo "- Should auto-respond '1' to first prompt"
echo "- Should pause for component name question"
echo "- Should pause for framework question" 
echo "- Should pause at completion message"