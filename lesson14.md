# lekce 14 poznamky

docker build -t 563748388258.dkr.ecr.eu-central-1.amazonaws.com/mynginx:latest .
docker push 563748388258.dkr.ecr.eu-central-1.amazonaws.com/mynginx:latest

aws ecr get-login-password --region eu-central-1 \
  | docker login --username AWS --password-stdin 563748388258.dkr.ecr.eu-central-1.amazonaws.com


curl http://ecs-nginx-demo-alb-2127282110.eu-central-1.elb.amazonaws.com/nginx_status

Povedlo se, 

ted pridat cloudwatch agenta aby monitoroval novou metriku
vlozin config pro agenta v jsonu
potom ten json volat v druhem kontejneru v ecs service
potom vytvorit alarm + sns na notifikaci mailem

Vytvoril jsem vse a deploy ale nechce mi startovat agent

zkusim upravit image aby bral agent config z image

terraform apply -replace=aws_ecs_task_definition.lesson7

make separete docker for agent
docker build -t my-cw-agent:latest .
docker tag my-cw-agent:latest 563748388258.dkr.ecr.eu-central-1.amazonaws.com/mynginx:cwagent
docker push 563748388258.dkr.ecr.eu-central-1.amazonaws.com/mynginx:cwagent

posrany agent nefunguje

curl http://ecs-nginx-demo-alb-2127282110.eu-central-1.elb.amazonaws.com/nonexistent