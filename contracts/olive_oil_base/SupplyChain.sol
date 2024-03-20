// SPDX-License-Identifier: MIT

pragma solidity >=0.6.00;

// Importing the necessary sol files
import "../olive_oil_core/Ownable.sol";
import "../olive_oil_access_control/ConsumerRole.sol";
import "../olive_oil_access_control/DistributorRetailerRole.sol";
import "../olive_oil_access_control/FarmerRole.sol";
import "../olive_oil_access_control/Producer.sol";
import "../olive_oil_access_control/Inspector.sol";

// Define a contract 'Supplychain'
contract SupplyChain is
    Ownable,
    FarmerRole,
    InspectorRole,
    DistributorRole,
    ConsumerRole,
    ProducerRole
{
    // Define a variable called 'sku' for Stock Keeping Unit (SKU)
    uint256 sku_cnt;

    // olives_upc -> olivesItem
    mapping(uint256 => olivesItem) olivesItems;
    // oliveOil_upc -> oliveOilItems
    mapping(uint256 => oliveOilItem) oliveOilItems;
    // oliveOil_upc -> olives_upc[]
    mapping(uint256 => uint256[]) oliveOilOlives;

    // Define enum 'State' with the following values:
    enum OlivesState {
		Planted,
		Harvested,
		Audited,
		Processed
	}
    OlivesState constant defaultOlivesState = OlivesState.Planted;

    enum OliveOilState {
        Created,
        Blended,
        Produced,
        Certified,
        Packed,
        ForSale,
        Purchased
    }
    OliveOilState constant defaultOliveOilState = OliveOilState.Created;

    // Define a struct 'OlivesItem' with the following fields:
    struct OlivesItem {
        uint256 sku; // Stock Keeping Unit (SKU)
        uint256 upc; // Universal Product Code (UPC), generated by the Farmer, goes on the package, can be verified by the Consumer
        address ownerID; // Metamask-Ethereum address of the current owner as the product moves through stages
        address originFarmerID; // Metamask-Ethereum address of the Farmer
        string originFarmName; // Farmer Name
        string originFarmInformation; // Farmer Information
        string originFarmLatitude; // Farm Latitude
        string originFarmLongitude; // Farm Longitude
        string harvestNotes; // Harvest Notes
        string auditNotes; // Autit Notes
        OlivesState itemState; // Product State as represented in the enum above
    }

    // Define a struct 'OliveOilItem' with the following fields:
    struct OliveOilItem {
        uint256 sku; // Stock Keeping Unit (SKU)
        uint256 upc; // Universal Product Code (UPC), generated by the Procuder, goes on the package, can be verified by the Consumer
        address ownerID; // Metamask-Ethereum address of the current owner as the product moves through stages
        uint256 productID; // Product ID potentially a combination of upc + sku
        string productNotes; // Product Notes
        uint256 productPrice; // Product Price
        address producerID; // Metamask-Ethereum address of the Producer
        address distributorID; // Metamask-Ethereum address of the Distributor
        address consumerID; // Metamask-Ethereum address of the Consumer
        string certifyNotes; // Certify Notes
        OliveOilState itemState; // Product State as represented in the enum above
    }

    // Define events of Olives
    event OlivesPlanted(uint256 olivesUpc);
    event OlivesHarvested(uint256 olivesUpc);
    event OlivesAudited(uint256 olivesUpc);
    event OlivesProcessed(uint256 olivesUpc);

    // Define events of OliveOil
    event OliveOilCreated(uint256 oliveOilUpc);
    event OliveOilBlended(uint256 oliveOilUpc, uint256 olivesUpc);
    event OliveOilProduced(uint256 oliveOilUpc);
    event OliveOilPacked(uint256 oliveOilUpc);
    event OliveOilCertified(uint256 oliveOilUpc);
    event OliveOilForSale(uint256 oliveOilUpc);
    event OliveOilPurchased(uint256 oliveOilUpc);

    // Define a modifer that verifies the Caller
    modifier verifyCaller(address _address) {
        require(msg.sender == _address, "verifyCaller: unexpected caller");
        _;
    }

    // Define a modifier that checks if the paid amount is sufficient to cover the price
    modifier paidEnough(uint256 _price) {
        require(msg.value >= _price, "paidEnough");
        _;
    }

    // Define a modifier that checks the price and refunds the remaining balance
    modifier checkValue(uint256 _oliveOilUpc) {
        _;
        uint256 _price = oliveOilItems[_oliveOilUpc].productPrice;
        uint256 amountToReturn = msg.value - _price;
        payable(oliveOilItems[_oliveOilUpc].consumerID).transfer(amountToReturn);
    }

    // Define a modifier that checks if an olivesItem.state of a upc is Planted
    modifier isPlanted(uint256 _olivesUpc) {
        require(olivesItems[_olivesUpc].itemState == OlivesState.Planted, "not Planted");
        _;
    }

    // Define a modifier that checks if an olivesItem.state of a upc is Harvested
    modifier isHarvested(uint256 _olivesUpc) {
        require(olivesItems[_olivesUpc].itemState == OlivesState.Harvested, "not Harvested");
        _;
    }

    // Define a modifier that checks if an olivesItem.state of a upc is Audited
    modifier isAudited(uint256 _olivesUpc) {
        require(olivesItems[_olivesUpc].itemState == OlivesState.Audited, "not Audited");
        _;
    }

    // Define a modifier that checks if an olivesItem.state of a upc is Processed
    modifier isProcessed(uint256 _olivesUpc) {
        require(olivesItems[_olivesUpc].itemState == OlivesState.Processed, "not Processed");
        _;
    }

    // Define a modifier that checks if an oliveOilItem.state of a upc is Created
    modifier isCreated(uint256 _oliveOilUpc) {
        require(oliveOilItems[_oliveOilUpc].itemState == OliveOilState.Created, "not Created");
        _;
    }

    // Define a modifier that checks if an oliveOilItem.state of a upc is Blended
    modifier isBlended(uint256 _oliveOilUpc) {
        require(oliveOilItems[_oliveOilUpc].itemState == OliveOilState.Blended, "not Blended");
        _;
    }

    // Define a modifier that checks if an oliveOilItem.state of a upc is Produced
    modifier isProduced(uint256 _oliveOilUpc) {
        require(oliveOilItems[_oliveOilUpc].itemState == OliveOilState.Produced, "not Produced");
        _;
    }

    // Define a modifier that checks if an oliveOilItem.state of a upc is Packed
    modifier isPacked(uint256 _oliveOilUpc) {
        require(oliveOilItems[_oliveOilUpc].itemState == OliveOilState.Packed, "not Packed");
        _;
    }

    // Define a modifier that checks if an oliveOilItem.state of a upc is Certified
    modifier isCertified(uint256 _oliveOilUpc) {
        require(oliveOilItems[_oliveOilUpc].itemState == OliveOilState.Certified, "not Certified");
        _;
    }

    // Define a modifier that checks if an oliveOilItem.state of a upc is ForSale
    modifier isForSale(uint256 _oliveOilUpc) {
        require(oliveOilItems[_oliveOilUpc].itemState == OliveOilState.ForSale, "not ForSale");
        _;
    }

    // Define a modifier that checks if an oliveOilItem.state of a upc is Purchased
    modifier isPurchased(uint256 _oliveOilUpc) {
        require(oliveOilItems[_oliveOilUpc].itemState == OliveOilState.Purchased, "not Purchased");
        _;
    }

    // In the constructor
    // set 'sku' to 1
    // set 'upc' to 1
    constructor() public payable {
        sku_cnt = 1;
    }

    // Transfer Eth to owner and terminate contract
    function kill() public onlyOwner {
        selfdestruct(payable(owner()));
    }

    // Define a function 'olivesPlantItem' that allows a farmer to mark an item 'Planted'
    function olivesPlantItem(
        uint256 _olivesUpc,
        address _originFarmerID,
        string calldata _originFarmName,
        string calldata _originFarmInformation,
        string calldata _originFarmLatitude,
        string calldata _originFarmLongitude
    ) public onlyFarmer {
        // Add the new item as part of Harvest
        olivesItems[_olivesUpc].sku = sku_cnt;
        olivesItems[_olivesUpc].upc = _olivesUpc;
        olivesItems[_olivesUpc].ownerID = msg.sender;
        olivesItems[_olivesUpc].originFarmerID = _originFarmerID;
        olivesItems[_olivesUpc].originFarmName = _originFarmName;
        olivesItems[_olivesUpc].originFarmInformation = _originFarmInformation;
        olivesItems[_olivesUpc].originFarmLatitude = _originFarmLatitude;
        olivesItems[_olivesUpc].originFarmLongitude = _originFarmLongitude;
        // Update state
        olivesItems[_olivesUpc].itemState = OlivesState.Planted;
        // Increment sku
        sku_cnt = sku_cnt + 1;
        // Emit the appropriate event
        emit OlivesPlanted(_olivesUpc);
    }

    // Define a function 'olivesHarvestItem' that allows a farmer to mark an item 'Harvested'
    function olivesHarvestItem(uint256 _olivesUpc, string calldata _harvestNotes)
        public
        onlyFarmer
        isPlanted(_olivesUpc)
    {
        // Add the new item as part of Harvest
        olivesItems[_olivesUpc].ownerID = msg.sender;
        olivesItems[_olivesUpc].harvestNotes = _harvestNotes;
        // Update state
        olivesItems[_olivesUpc].itemState = olivesState.Harvested;
        // Emit the appropriate event
        emit OlivesHarvested(_olivesUpc);
    }

    // Define a function 'olivesAuditItem' that allows a Inspector to mark an item 'Audited'
    function olivesAuditItem(uint256 _olivesUpc, string calldata _auditNotes)
        public
        onlyInspector
        isHarvested(_olivesUpc)
    {
        // Add the new item as part of Harvest
        olivesItems[_olivesUpc].auditNotes = _auditNotes;
        // Update state
        olivesItems[_olivesUpc].itemState = OlivesState.Audited;
        // Emit the appropriate event
        emit OlivesAudited(_olivesUpc);
    }

    // Define a function 'olivesProcessItem' that allows a farmer to mark an item 'Processed'
    function olivesProcessItem(uint256 _olivesUpc)
        public
        onlyFarmer
        isAudited(_olivesUpc)
        // verifyCaller(olivesItems[_olivesUpc].ownerID) // Call modifier to verify caller of this function
    {
        // Update the appropriate fields
        olivesItems[_olivesUpc].itemState = OlivesState.Processed;
        // Emit the appropriate event
        emit OlivesProcessed(_olivesUpc);
    }

    function oliveOilCreateItem(
        uint256 _olivesUpc,
        uint256 _productID
    ) public onlyProducer {
        // Add the new item as part of Harvest
        oliveOilItems[_olivesUpc].sku = sku_cnt;
        oliveOilItems[_olivesUpc].upc = _olivesUpc;
        oliveOilItems[_olivesUpc].productID = _productID;
        oliveOilItems[_olivesUpc].ownerID = msg.sender;
		// Update state
        oliveOilItems[_olivesUpc].itemState = OliveOilState.Created;
        // Increment sku
        sku_cnt = sku_cnt + 1;
        // Emit the appropriate event
        emit OliveOilCreated(_olivesUpc);
    }

    function oliveOilBlendItem(uint256 _oliveOilUpc, uint256 _olivesUpc)
        public
        onlyProducer
		verifyCaller(oliveOilItems[_oliveOilUpc].ownerID)
    {
		// Take ownership of olives
		olivesItems[_oliveOilUpc].ownerID = msg.sender;
		// Blend the '_oliveOilUpc' oliveOil with '_olivesUpc' olives
		oliveOilOlives[_oliveOilUpc].push(_olivesUpc);
		// Update state
        oliveOilItems[_oliveOilUpc].itemState = OliveOilState.Blended;
        // Emit the appropriate event
        emit OliveOilBlended(_oliveOilUpc, _olivesUpc);
    }

	function oliveOilProduceItem(uint256 _oliveOilUpc, string calldata _productNotes, uint256 _productPrice)
        public
        onlyProducer
		verifyCaller(oliveOilItems[_oliveOilUpc].ownerID)
		isBlended(_oliveOilUpc)
    {
        oliveOilItems[_oliveOilUpc].producerID = msg.sender;
        oliveOilItems[_oliveOilUpc].productNotes = _productNotes;
        oliveOilItems[_oliveOilUpc].productPrice = _productPrice;
		// Update state
        oliveOilItems[_oliveOilUpc].itemState = OliveOilState.Produced;
        // Emit the appropriate event
        emit OliveOilProduced(_oliveOilUpc);
    }

	function oliveOilCertifyItem(uint256 _oliveOilUpc, string calldata _certifyNotes)
        public
        onlyInspector
		isProduced(_oliveOilUpc)
    {
		oliveOilItems[_oliveOilUpc].certifyNotes = _certifyNotes;
		// Update state
        oliveOilItems[_oliveOilUpc].itemState = OliveOilState.Certified;
        // Emit the appropriate event
        emit OliveOilCertified(_oliveOilUpc);
    }

	function oliveOilPackItem(uint256 _oliveOilUpc)
        public
        onlyProducer
		verifyCaller(olivesItems[_oliveOilUpc].ownerID)
		isCertified(_oliveOilUpc)
    {
		// Update state
        oliveOilItems[_oliveOilUpc].itemState = OliveOilState.Packed;
        // Emit the appropriate event
        emit OliveOilPacked(_oliveOilUpc);
    }

	function oliveOilSellItem(uint256 _oliveOilUpc)
        public
        onlyDistributor
		isPacked(_oliveOilUpc)
    {
        oliveOilItems[_oliveOilUpc].distributorID = msg.sender;
		// Update state
        oliveOilItems[_oliveOilUpc].itemState = OliveOilState.ForSale;
        // Emit the appropriate event
        emit OliveOilForSale(_oliveOilUpc);
    }

	function oliveOilBuyItem(uint256 _oliveOilUpc)
        public
		payable
        onlyConsumer
		isForSale(_oliveOilUpc)
		paidEnough(oliveOilItems[_oliveOilUpc].productPrice)
		checkValue(_oliveOilUpc)
    {
		oliveOilItems[_oliveOilUpc].ownerID = msg.sender;
        oliveOilItems[_oliveOilUpc].consumerID = msg.sender;
		// Update state
        oliveOilItems[_oliveOilUpc].itemState = OliveOilState.Purchased;
        // Transfer money to producer
        uint256 price = oliveOilItems[_oliveOilUpc].productPrice;
        payable(oliveOilItems[_oliveOilUpc].producerID).transfer(price);
        // Emit the appropriate event
	    emit OliveOilPurchased(_oliveOilUpc);
    }

    // Functions to fetch data
    function fetchOliveOilItemBufferOne(uint256 _oliveOilUpc)
        external
        view
        returns (
			uint256 sku,
			uint256 upc,
			address ownerID,
			uint256 productID,
			string memory productNotes,
			uint256 productPrice,
			address producerID,
			address distributorID,
			address consumerID,
			string memory certifyNotes,
			uint256[] memory olives,
			uint256 itemState
        )
    {
			sku			= oliveOilItems[_oliveOilUpc].sku;
			upc			= oliveOilItems[_oliveOilOilUpc].upc;
			ownerID		= oliveOilItems[_oliveOilUpc].ownerID;
			productID		= oliveOilItems[_oliveOilUpc].productID;
			productNotes	= oliveOilItems[_oliveOilUpc].productNotes;
			productPrice	= oliveOilItems[_oliveOilUpc].productPrice;
			producerID		= oliveOilItems[_oliveOilUpc].producerID;
			distributorID	= oliveOilItems[_oliveOilUpc].distributorID;
			consumerID		= oliveOilItems[_oliveOilUpc].consumerID;
			certifyNotes	= oliveOilItems[_oliveOilUpc].certifyNotes;
			olives			= oliveOilOlives[_oliveOilUpc];
			itemState		= uint256(oliveOilItems[_oliveOilUpc].itemState);
        return (
			sku,
			upc,
			ownerID,
			productID,
			productNotes,
			productPrice,
			producerID,
			distributorID,
			consumerID,
			certifyNotes,
			olives,
			itemState
        );
    }

    // Functions to fetch data
    function fetchOlivesItemBufferOne(uint256 _olivesUpc)
        public
        view
        returns (
			uint256 sku,
			uint256 upc,
			address ownerID,
			address originFarmerID,
			string memory originFarmName,
			string memory originFarmInformation,
			string memory originFarmLatitude,
			string memory originFarmLongitude
        )
    {
			sku			= olivesItems[_olivesUpc].sku;
			upc			= olivesItems[_olivesUpc].upc;
			ownerID			= olivesItems[_olivesUpc].ownerID;
			originFarmerID	= olivesItems[_olivesUpc].originFarmerID;
			originFarmName	= olivesItems[_olivesUpc].originFarmName;
			originFarmInformation	= olivesItems[_olivesUpc].originFarmInformation;
			originFarmLatitude		= olivesItems[_olivesUpc].originFarmLatitude;
			originFarmLongitude		= olivesItems[_olivesUpc].originFarmLongitude;
        return (
			sku,
			upc,
			ownerID,
			originFarmerID,
			originFarmName,
			originFarmInformation,
			originFarmLatitude,
			originFarmLongitude
        );
    }


    // Functions to fetch data
    function fetchOlivesItemBufferTwo(uint256 _olivesUpc)
        public
        view
        returns (
			string memory harvestNotes,
			string memory auditNotes,
			uint256 itemState
        )
    {
			harvestNotes	= olivesItems[_olivesUpc].harvestNotes;
			auditNotes		= olivesItems[_olivesUpc].auditNotes;
			itemState 		= uint256(olivesItems[_olivesUpc].itemState);
        return (
			harvestNotes,
			auditNotes,
			itemState
        );
    }

}
