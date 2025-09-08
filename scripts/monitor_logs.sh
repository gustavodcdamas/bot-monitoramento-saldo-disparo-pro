#!/bin/bash

echo "🔍 Monitorando logs em tempo real..."
echo "📊 Logs disponíveis:"
echo "  1. disparopro.log - Logs principais"
echo "  2. debug.log - Logs detalhados"
echo "  3. teams.log - Logs do Teams"
echo "  4. Todos os logs"
echo "📝 Use Ctrl+C para parar"

echo -n "Selecione o log para monitorar (1-4): "
read choice

case $choice in
    1)
        echo "📋 Monitorando disparopro.log..."
        tail -f /var/log/cron/disparopro.log | while read line; do
            echo "$(date '+%H:%M:%S') - $line"
        done
        ;;
    2)
        echo "🐛 Monitorando debug.log..."
        tail -f /var/log/cron/debug.log | while read line; do
            echo "$(date '+%H:%M:%S') - $line"
        done
        ;;
    3)
        echo "💬 Monitorando teams.log..."
        tail -f /var/log/cron/teams.log | while read line; do
            echo "$(date '+%H:%M:%S') - $line"
        done
        ;;
    4)
        echo "📊 Monitorando todos os logs..."
        tail -f /var/log/cron/disparopro.log /var/log/cron/debug.log /var/log/cron/teams.log | while read line; do
            echo "$(date '+%H:%M:%S') - $line"
        done
        ;;
    *)
        echo "📁 Monitorando todos os logs..."
        tail -f /var/log/cron/disparopro.log /var/log/cron/debug.log /var/log/cron/teams.log | while read line; do
            echo "$(date '+%H:%M:%S') - $line"
        done
        ;;
esac