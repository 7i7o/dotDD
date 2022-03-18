# .devdao domain service

Install all the contract deps with 

```bash
npm install
```

Deploy only with 

```bash
npm hardhat run scripts/deploy-only.js
```

or

```bash
npm hardhat run scripts/deploy-and-populate.js
```

If you need to deploy to mumbai, please create a `.env` from `env.example`, populate it and run:

```bash
npm hardhat run scripts/deploy-and-populate.js --network mumbai
```

Inside the folder `frontend` there's a basic UI (create-react-app). Enter that folder and install deps:

```bash
npm install
```

Then you can update `CONTRACT_ADDRESS` on `frontend/src/App.js` with the address of your deployed contract (local or mumbai). Then run:

```bash
npm start
```

to start a web server on localhost:3000
