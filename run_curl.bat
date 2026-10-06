@echo off
curl -X POST "https://ebvphaasxmltvedzblhq.supabase.co/auth/v1/signup" ^
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVidnBoYWFzeG1sdHZlZHpibGhxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM0ODYyOTcsImV4cCI6MjA4OTA2MjI5N30.LD09QI8fUCA2Def-J9T1AvfOjk2wuNOQ9nr-IdkKfLA" ^
  -H "Content-Type: application/json" ^
  -d @payload.json
