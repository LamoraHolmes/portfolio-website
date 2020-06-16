#!/bin/bash


if [ "$Status" = "Plan" ]
    then
        echo "Entering Planning Stage"
        terraform init
        terraform plan -no-color -input=false -out a
        echo "Leavin Planning Stage"
        
elif [ "$Status" = "Apply" ]
    then
        echo "Entering Apply Stage"
        terraform apply -input=false a
        #terraform destroy -auto-approve 
        echo "Leavin Apply Stage"
fi


