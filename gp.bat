@echo off
call git add --all
call git commit -m %1
call git push origin master