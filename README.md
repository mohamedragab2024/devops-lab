📝 devops-lab
-------------
Documentation for [Gitops youtube series][playlist-link] and more.

🦦 Table of contents
--------------------

<!-- <div align="center"> -->

Number | Topic | link
:--:|:--:|:--:
1 | azure | [🔗][azure-link]
2 | docker | [🔗][docker-link]
3 | dotnet | [🔗][dotnet-link]
4 | gitlab | [🔗][gitlab-link]
5 | kubernetes | [🔗][kubernetes-link]

<!-- </div> -->

☁️ Azure 
-------
<details>
<summary>Click me</summary>
<br/>
....
</details>

🐳 Docker
---------
<details>
<summary>Click me</summary>

### 📝 Install kubectl inside ubuntu contanier
The showed-below Dockerfile sets up an Ubuntu-based container with kubectl and Python 3 installed.
```Dockerfile
FROM  ubuntu
RUN apt-get update
RUN apt-get install -y apt-transport-https ca-certificates curl
RUN apt-get install -y gnupg
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install -y kubectl
RUN apt update
RUN apt install python3  -y
```
</details>

👹 dotnet
---------
<details>
<summary>Click me</summary>
....
</details>

🦝 Gitlab
---------
<details>
<summary>Click me</summary>
....
</details>

🐙 kubernetes
-------------
<details>
<summary>Click me</summary>
....
</details>


[playlist-link]: https://www.youtube.com/watch?v=f85XlAjbS5w&list=PLTRDUPO2OmInz2Fo41zwnoR1IArx70Hig
[azure-link]: #-azure
[docker-link]: #-docker
[dotnet-link]: #-dotnet
[gitlab-link]: #-gitlab
[kubernetes-link]: #-kubernetes
