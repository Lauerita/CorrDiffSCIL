
k8s_connect_prompt() {
    echo "Would you like to connect to a Kubernetes pod? (y/n)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Creating deployment..."
        kubectl create -f jupyter-deployment-laurahu.yaml -n sdsu-shen-climate-lab
	
	sleep 5
        
        echo "\nCurrent pods:"
	kubectl get pods -n sdsu-shen-climate-lab | grep jupyter-deployment-laurahu

        
        echo "\nEnter pod name: "
        read -r pod_name

	sleep 5
        
        if [[ -n "$pod_name" ]]; then
            echo "\nFetching logs for $pod_name..."
            kubectl logs "$pod_name" -n sdsu-shen-climate-lab
            echo "\nSuccessfully retrieved logs!"

	    osascript -e "tell application \"Terminal\" to do script \"kubectl port-forward $pod_name -n sdsu-shen-climate-lab 8888:8888\""
	    echo "Port forwarding in another window."
	fi
    fi
}



nim_connect_prompt(){
    echo "Would you like to connect to a NIM pod (y/n)?"
    read -r response 
    
    if [[ "$response" =~ ^[Yy]$ ]]; then 
        echo "Creating NIM deployment..."
        kubectl create -f corrdiff-nim-deployment-laurahu.yaml -n sdsu-shen-climate-lab
        
        echo "Getting pods..."
        kubectl get pods -n sdsu-shen-climate-lab | grep corrdiff

	sleep 5 
        
        status=$(kubectl get pod corrdiff-nim-laurahu -n sdsu-shen-climate-lab -o jsonpath='{.status.phase}')
	
        
        if [[ "$status" == "Running" ]]; then 
            echo "Pod is running!"
            kubectl logs -f deployment/corrdiff-nim-laurahu -n sdsu-shen-climate-lab
        else 
	    echo "Please wait for the container to be created..."
	    kubectl get pods -n sdsu-shen-climate-lab -w | grep corrdiff 

        fi
    fi
}



delete_deployment_prompt(){

	echo "Which deployment would you like to delete?"
	echo "1) Delete JupyterHub"
	echo "2) Delete NIM(CorrDiff)"
	echo "3) Cancel"
	read -r choice 
	

	case $choice in 

		1) 

			kubectl delete deployment jupyter-deployment-laurahu -n sdsu-shen-climate-lab
			;;

		2) 

			kubectl delete deployment corrdiff-nim-laurahu -n sdsu-shen-climate-lab
			kubectl delete service corrdiff-nim-service-laurahu -n sdsu-shen-climate-lab
			;;
		3) 
			echo "Cancel deletion."
			;;

	esac
}



main_k8s_prompt(){
	echo "Which deployment would you like to use?"
	echo "1) JupyterHub"
	echo "2) NIM (CorrDiff)"
	echo "3) Delete deployments"
	echo "4) Skip"
	read -r choice

	case $choice in
		1) 
			k8s_connect_prompt
			;;

		2)
			nim_connect_prompt
			;;

		3) 
			delete_deployment_prompt
			;;

		4)
			echo "Have a good day!"
			;;
	esac

}
