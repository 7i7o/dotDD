import React, { useEffect, useState } from 'react';
import { networks } from './utils/networks';

import './App.css';
import ddLogo from './assets/D_D.svg';
import polygonLogo from './assets/polygonlogo.png';
import ethLogo from './assets/ethlogo.png';
import contractABI from './contracts/contract-artifact.json';
import { ethers } from 'ethers';

import { ToastContainer, toast } from 'react-toastify';

const tld = '.devdao';

// const CONTRACT_ADDRESS = '0xF139bCaF0f992134C89D7E06664B99DF5c8A568D'; // First Iteration
// const CONTRACT_ADDRESS = '0xc9A30b6afbefCDf2b90EDCa7DceD6a1Ccbac4743'; // Second Iteration
const CONTRACT_ADDRESS = '0x7B2812F7E2F857b756886222d54dd63657f89c4C'; // Third Iteration

const OpenSeaLink = (props) => {
  return (
    <a className="link" href={`https://testnets.opensea.io/assets/mumbai/${props.contract}/${props.mintId}`} target="_blank" rel="noopener noreferrer">
      <p className="underlined">{' '}{props.linkName}{' '}</p>
    </a>
  );
}

const Msg = (props) => (
  <div>
    <p>{props.message}</p>
    {props.toastLink ? props.toastLink : ''}
  </div>
);

function App() {

  // State Variables
  const [network, setNetwork] = useState('');
  const [currentAccount, setCurrentAccount] = useState('');
  const [domain, setDomain] = useState('');
  const [loading, setLoading] = useState(false);
  // const [record, setRecord] = useState('');
  // const [editing, setEditing] = useState(false);
  const [accountDomains, setAccountDomains] = useState([]);

  // Connection
  const connectWallet = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        alert("Get MetaMask -> https://metamask.io/");
        return;
      }

      const accounts = await ethereum.request({ method: "eth_requestAccounts" });

      console.log("Connected", accounts[0]);
      setCurrentAccount(accounts[0]);
    } catch (error) {
      console.log(error)
    }
  }

  const checkIfWalletIsConnected = async () => {
    const { ethereum } = window;
    if (!ethereum) {
      console.log("Make sure you have MetaMask!");
      return;
    } else {
      console.log("We have the ethereum object", ethereum);
    }
    const accounts = await ethereum.request({ method: 'eth_accounts' });
    if (accounts.length !== 0) {
      const account = accounts[0];
      console.log('Found an authorized account:', account);
      setCurrentAccount(account);
    } else {
      console.log('No authorized account found');
    }
    const chainId = await ethereum.request({ method: 'eth_chainId' });
    setNetwork(networks[chainId]);
    // Reload page on network change
    ethereum.on('chainChanged', handleChainChanged);
    function handleChainChanged(_chainId) {
      window.location.reload();
    }
  }

  const switchNetwork = async () => {
    if (window.ethereum) {
      try {
        await window.ethereum.request({
          method: 'wallet_switchEthereumChain',
          params: [{ chainId: '0x13881' }], // Check networks.js for hexadecimal network ids
        });
      } catch (error) {
        // If user doesn't have Mumbai on Metamask, we ask to add it.
        if (error.code === 4902) {
          try {
            await window.ethereum.request({
              method: 'wallet_addEthereumChain',
              params: [
                {
                  chainId: '0x13881',
                  chainName: 'Polygon Mumbai Testnet',
                  rpcUrls: ['https://rpc-mumbai.maticvigil.com/'],
                  nativeCurrency: {
                    name: "Mumbai Matic",
                    symbol: "MATIC",
                    decimals: 18
                  },
                  blockExplorerUrls: ["https://mumbai.polygonscan.com/"]
                },
              ],
            });
          } catch (error) {
            console.log(error);
          }
        }
        console.log(error);
      }
    } else {
      // If window.ethereum is not found then MetaMask is not installed
      alert('MetaMask is not installed. Please install it to use this app: https://metamask.io/download.html');
    }
  }

  // Hooks for app changes
  useEffect(() => {
    checkIfWalletIsConnected();
  }, [])

  useEffect(() => {
    if (network === 'Polygon Mumbai Testnet' && currentAccount) {
      fetchDomains();
    }
  }, [currentAccount, network]);

  // Contract Interactions
  const mintDomain = async () => {

    if (!domain) { return }

    if (domain.length < 3) {
      alert('Domain must be at least 3 characters long');
      return;
    }

    if (domain.length > 12) {
      alert('Domain must be at most 12 characters long');
      return;
    }

    // const price = domain.length === 3 ? '0.5' : domain.length === 4 ? '0.1' : '0.05';
    const price = '0';

    console.log("Minting domain ", domain, " with price ", price);
    try {
      const { ethereum } = window;
      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(CONTRACT_ADDRESS, contractABI.abi, signer);

        console.log("Going to pop wallet now to pay gas...")

        let tx = await contract.mint(domain);//,  {value: ethers.utils.parseEther(price)});
        const receipt = await tx.wait();


        if (receipt.status === 1) {

          const event = receipt.events.find(event => event.event === 'Transfer');
          const [from, to, tokenId] = event.args;
          console.log(from, to, tokenId);
          const mintId = tokenId;

          console.log("Domain minted! https://mumbai.polygonscan.com/tx/" + tx.hash);

          setTimeout(() => {
            notify("DevDao Domain minted! ", <OpenSeaLink contract={CONTRACT_ADDRESS} mintId={mintId} linkName={domain + tld} />)
            fetchDomains();
          }, 2000); // Call fetchMints after 2 seconds


          // setRecord('');
          setDomain('');
        }
        else {
          alert("Transaction failed! Please try again");
        }
      }
    }
    catch (error) {
      console.log(error);
    }
  }

  const fetchDomains = async () => {
    try {
      const { ethereum } = window;
      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(CONTRACT_ADDRESS, contractABI.abi, signer);

        const domainCount = await contract.balanceOf(currentAccount);
        if (domainCount < 1) {
          setAccountDomains([]);
          return;
        }

        const domainIds = [...Array(domainCount).keys()];

        const domains = await Promise.all(domainIds.map(async (domainIndex) => {
          console.log(`DomainIndex ${domainIndex}`);
          const domainName = await contract.domainOfOwnerByIndex(currentAccount, domainIndex);
          console.log(`DomainName ${domainName}`);
          const domainInfo = await contract.getInfoByDomain(domainName);
          console.log(`DomainInfo ${domainInfo}`);
          return {
            id: domainIndex,
            name: domainInfo.domain,
            domainInfo: domainInfo,
            owner: currentAccount,
          };
        }));

        console.log("DOMAINS FETCHED ", domains);
        setAccountDomains(domains);
      }
    } catch (error) {
      console.log(error);
    }
  }

  // Render
  const notify = (message, link) => toast(<Msg message={message} toastLink={link} />);

  const renderNotConnectedContainer = () => (
    <div className="connect-wallet-container">
      <button onClick={connectWallet} className="cta-button connect-wallet-button" >
        Connect Wallet
      </button>
    </div>
  );

  const renderInputForm = () => {
    if (network !== 'Polygon Mumbai Testnet') {
      return (
        <div className="connect-wallet-container">
          <p>Please connect to the Polygon Mumbai Testnet</p>
          <button className='cta-button mint-button' onClick={switchNetwork}>Click here to switch</button>
        </div>
      );
    }
    return (
      <div className="form-container">
        <div className="first-row">
          <input
            type="text"
            value={domain}
            placeholder='domain'
            onChange={e => setDomain(e.target.value)}
          />
          <p className='tld'> {tld} </p>
        </div>

        {/* <input
            type="text"
            value={record}
            placeholder='who u be in real life?'
            onChange={e => setRecord(e.target.value)}
          /> */}

        <div className="button-container">
          {/* {editing ? (
              <div className="button-container">
                <button className='cta-button mint-button' disabled={loading} onClick={updateDomain}>
                  Set record
                </button>  
                <button className='cta-button mint-button' onClick={() => {setEditing(false); setDomain('');}}>
                  Cancel
                </button>  
              </div>
            ) : ( */}
          <button className='cta-button mint-button' disabled={loading} onClick={mintDomain}>
            Mint
          </button>
          {/* )} */}
        </div>

      </div>
    );
  }

  const renderDomains = () => {
    if (currentAccount && accountDomains.length > 0) {
      return (
        <div className="mint-container">
          <p className="subtitle"> Your <code>.devdao</code> domains:</p>
          <div className="mint-list">
            {accountDomains.map((mint, index) => {
              return (
                <div className="mint-item" key={index}>
                  <div className='mint-row'>
                    <a className="link" href={`https://testnets.opensea.io/assets/mumbai/${CONTRACT_ADDRESS}/${mint.id}`} target="_blank" rel="noopener noreferrer">
                      <p className="underlined"><code>{' '}{mint.name}{tld}{' '}</code></p>
                    </a>
                    {/* If mint.owner is currentAccount, add an "edit" button*/}
                    {/* {mint.owner.toLowerCase() === currentAccount.toLowerCase() ?
                      <button className="edit-button" onClick={() => editRecord(mint.name)}>
                        <img className="edit-icon" src={pencil} alt="Edit button" />
                      </button>
                      :
                      null
                    } */}
                  </div>
                  {/* <p> {mint.record} </p> */}
                </div>)
            })}
          </div>
        </div>);
    }
  };

  // Main App Page Render
  return (
    <div className="App">

      <ToastContainer autoClose={8000} position={toast.POSITION.TOP_CENTER} />

      <div className="App-header">
        <br />
        <img src={ddLogo} alt="" className="dd-logo" />
        <h1>DevDAO Domains</h1>
        <p>Mint your own <code>.devdao</code> domain</p>
        <div className="wallet-info wallet-info-container">
          <img alt="Network logo" className="logo" src={network.includes("Polygon") ? polygonLogo : ethLogo} />
          {currentAccount ? <p> Wallet: {currentAccount.slice(0, 6)}...{currentAccount.slice(-4)} </p> : <p> Not connected </p>}
        </div>
        {!currentAccount && renderNotConnectedContainer()}
        {currentAccount && renderInputForm()}
        {accountDomains && renderDomains()}
      </div>
    </div>
  );
}

export default App;
