import { useState, useEffect } from "react";
import { BrowserProvider, Contract, formatEther, parseEther } from "ethers";
import AuctionHouseABI from "./AuctionHouse/AuctionHouse.json"; // Ensure correct ABI path

const CONTRACT_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3"; // Replace with your deployed contract address

function App() {
    const [contract, setContract] = useState(null);
    const [auctions, setAuctions] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        async function connectWallet() {
            if (window.ethereum) {
                const provider = new BrowserProvider(window.ethereum);
                const signer = await provider.getSigner();

                const auctionContract = new Contract(CONTRACT_ADDRESS, AuctionHouseABI.abi, signer);
                setContract(auctionContract);

                await fetchAuctions(auctionContract);
            } else {
                alert("Please install MetaMask!");
            }
        }
        connectWallet();
    }, []);

    const fetchAuctions = async (auctionContract) => {
        try {
            setLoading(true);
            let auctionData = [];
            const auctionCount = Number(await auctionContract.auctionCount());

            for (let i = 0; i < auctionCount; i++) {
                const auction = await auctionContract.getAuction(i);
                auctionData.push({
                    id: i,
                    seller: auction.seller,
                    startingPrice: formatEther(auction.startingPrice),
                    highestBid: formatEther(auction.highestBid),
                    highestBidder: auction.highestBidder,
                    endTime: new Date(Number(auction.endTime) * 1000).toLocaleString(),
                    finalized: auction.finalized
                });
            }
            setAuctions(auctionData);
        } catch (error) {
            console.error("Error fetching auctions:", error);
        }
        setLoading(false);
    };

    const createAuction = async () => {
        try {
            const tx = await contract.createAuction(parseEther("1"), 100); //here is starting min Bid, endtime
            await tx.wait();
            alert("Auction Created!");
            fetchAuctions(contract);
        } catch (error) {
            console.error("Error creating auction:", error);
        }
    };

    const placeBid = async (auctionId) => {
        try {
            const tx = await contract.placeBid(auctionId, { value: parseEther("5") }); // changeing bid for again nextBid
            await tx.wait();
            alert("Bid Placed!");
            fetchAuctions(contract);
        } catch (error) {
            console.error("Error placing bid:", error);
        }
    };

    const finalizeAuction = async (auctionId) => {
        try {
            const tx = await contract.finalizeAuction(auctionId);
            await tx.wait();
            alert("Auction Finalized!");
            fetchAuctions(contract);
        } catch (error) {
            console.error("Error finalizing auction:", error);
        }
    };

    return (
        <div>
            <h1>Decentralized Auction House</h1>
            <button onClick={createAuction}>Create Auction</button>
            {loading ? <p>Loading auctions...</p> : (
                auctions.length === 0 ? <p>No auctions available.</p> :
                auctions.map((auction) => (
                    <div key={auction.id} style={{ border: "1px solid black", padding: "10px", margin: "10px" }}>
                        <p><strong>Seller:</strong> {auction.seller}</p>
                        <p><strong>Starting Price:</strong> {auction.startingPrice} ETH</p>
                        <p><strong>Highest Bid:</strong> {auction.highestBid} ETH</p>
                        <p><strong>Highest Bidder:</strong> {auction.highestBidder || "No bids yet"}</p>
                        <p><strong>Ends At:</strong> {auction.endTime}</p>
                        <p><strong>Status:</strong> {auction.finalized ? "Finalized" : "Active"}</p>

                        {!auction.finalized && (
                            <>
                                <button onClick={() => placeBid(auction.id)}>Place Bid</button>
                                <button onClick={() => finalizeAuction(auction.id)}>Finalize Auction</button>
                            </>
                        )}
                    </div>
                ))
            )}
        </div>
    );
}

export default App;
