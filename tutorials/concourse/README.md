# Running Concourse on VIC


### Step 1: Creating volumes for containers
docker volume create --opt Capacity=1GB --name postgres
docker volume create --opt Capacity=4GB --name concourse-keys
docker volume create --opt Capacity=4GB --name worker-state


### Step 2: Create docker network
docker network create concourse-net


### Step 3: Run the concourse-db container
docker run --name concourse-db \
  --net=concourse-net \
  -h concourse-postgres \
  -v postgres:/var/lib/postgresql/data \
  -p 5432:5432 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=vmware \
  -e POSTGRES_DB=atc \
  -d postgres

### Step 4: Run the Concourse Container
Change the external url in the command below to the fqdn/ip of your VCH. Also, change the DNS server to your environment's DNS server.
docker run  --name concourse -h concourse \
   -d -p 8080:8080 \
   --net=concourse-net \
   -v concourse-keys:/concourse-keys \
   -v worker-state:/worker-state \
   concourse/concourse quickstart \
   --add-local-user=vic:vmware \
   --main-team-local-user=vic \
   --external-url=http://vch1.tpm.com:8080 \
   --postgres-user=postgres \
   --postgres-password=vmware \
   --postgres-host=concourse-db \
   --worker-garden-dns-server 8.8.8.8

### Step 5: Navigate to concourse UI and login
Navigate to the 'external-url' defined in step 4 and verify that UI is reachable. Download and install the 'fly' binary on a suitable machine.
Login to concourse using vic/vmware from the UI.
