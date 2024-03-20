const { before } = require("lodash");

const SupplyChain = artifacts.require("SupplyChain");
const truffleAssert = require('truffle-assertions');

var accounts;
var owner;

contract('SupplyChain', (accs) => {
	accounts = accs;
	owner = accounts[0];
});

// Accounts
let acc_owner = accounts[0];	// Contract Owner account
let acc_farm_0 = accounts[1];	// Farm account
let acc_prod_0 = accounts[2];	// Producer account
let acc_insp_0 = accounts[3];	// Inspector account
let acc_dist_0 = accounts[4];	// Distributor account
let acc_cons_0 = accounts[5];	// Consumer account

let instance = null;

describe('Programmatic usage suite', function () {

	describe('#index', function () {

		it('can the Farmer plant a Olive', async function () {
			this.timeout(20000);

			instance = await SupplyChain.deployed();
			await instance.addFarmer(acc_farm_0, { from: acc_owner });
			await instance.addProducer(acc_prod_0, { from: acc_owner });
			await instance.addInspector(acc_insp_0, { from: acc_owner });
			await instance.addDistributor(acc_dist_0, { from: acc_owner });
			await instance.addConsumer(acc_cons_0, { from: acc_owner });

			let upc = 1;
			let ownerID = acc_farm_0;
			let originFarmerID = acc_farm_0;
			let originFarmName = "Aurora Farm";
			let originFarmInformation = "Bento Goncalves";
			let originFarmLatitude = "34.12345543";
			let originFarmLongitude = "34.12345543";
			let harvestNotes = "";
			let auditNotes = "";
			let itemState = 0;

			// Plant Olives
			let plant = await instance.olivePlantItem(upc,
				originFarmerID,
				originFarmName,
				originFarmInformation,
				originFarmLatitude,
				originFarmLongitude,
				{ from: acc_farm_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchOliveItemBufferOne.call(upc);
			let res2 = await instance.fetchOliveItemBufferTwo.call(upc);
			// console.log(res1, 'result buffer 1');
			// console.log(res2, 'result buffer 2');

			// Check results
			assert.equal(res1.upc, upc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.originFarmerID, originFarmerID, 'Error: Missing or Invalid originFarmerID');
			assert.equal(res1.originFarmName, originFarmName, 'Error: Missing or Invalid originFarmName');
			assert.equal(res1.originFarmInformation, originFarmInformation, 'Error: Missing or Invalid originFarmInformation');
			assert.equal(res1.originFarmLatitude, originFarmLatitude, 'Error: Missing or Invalid originFarmLatitude');
			assert.equal(res1.originFarmLongitude, originFarmLongitude, 'Error: Missing or Invalid originFarmLongitude');
			assert.equal(res2.harvestNotes, harvestNotes, 'Error: Missing or Invalid harvestNotes');
			assert.equal(res2.auditNotes, auditNotes, 'Error: Missing or Invalid auditNotes');
			assert.equal(res2.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(plant, 'Olives Planted');
		});


		it('can the Farmer harvest Olives ', async function () {
			this.timeout(20000);
			let upc = 1;
			let ownerID = acc_farm_0;
			let originFarmerID = acc_farm_0;
			let harvestNotes = "bordo wine";
			let itemState = 1;
			let harvest = await instance.olivesHarvestItem(upc, harvestNotes, { from: acc_farm_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchOlivesItemBufferOne.call(upc);
			let res2 = await instance.fetchOlivesItemBufferTwo.call(upc);
			// console.log(res1, 'result buffer 1');
			// console.log(res2, 'result buffer 2');

			assert.equal(res1.upc, upc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.originFarmerID, originFarmerID, 'Error: Missing or Invalid originFarmerID');
			assert.equal(res2.harvestNotes, harvestNotes, 'Error: Missing or Invalid harvestNotes');
			assert.equal(res2.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(harvest, 'Olives Harvested');
		});

		it('can the Inspector audit Olives', async function () {
			this.timeout(20000);
			let upc = 1;
			let ownerID = acc_farm_0;
			let originFarmerID = acc_farm_0;
			let auditNotes = "ISO9002 audit passed";
			let itemState = 2;
			let audited = await instance.OlivesAuditItem(upc, auditNotes, { from: acc_insp_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchOlivesItemBufferOne.call(upc);
			let res2 = await instance.fetchOlivesItemBufferTwo.call(upc);
			// console.log(res1, 'result buffer 1');
			// console.log(res2, 'result buffer 2');

			assert.equal(res1.upc, upc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.originFarmerID, originFarmerID, 'Error: Missing or Invalid originFarmerID');
			assert.equal(res2.auditNotes, auditNotes, 'Error: Missing or Invalid auditNotes');
			assert.equal(res2.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(audited, 'Olives Audited');
		});

		it('can the Farm process Olives', async function () {
			this.timeout(20000);
			let upc = 1;
			let ownerID = acc_farm_0;
			let originFarmerID = acc_farm_0;
			let itemState = 3;
			let processed = await instance.olivesProcessItem(upc, { from: acc_farm_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchOlivesItemBufferOne.call(upc);
			let res2 = await instance.fetchOlivesItemBufferTwo.call(upc);
			// console.log(res1, 'result buffer 1');
			// console.log(res2, 'result buffer 2');

			assert.equal(res1.upc, upc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.originFarmerID, originFarmerID, 'Error: Missing or Invalid originFarmerID');
			assert.equal(res2.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(processed, 'Olives Processed');
		});

		it('can the Producer create a Olive Oil', async function () {
			this.timeout(20000);
			let upc = 1;
			let productID = 1001;
			let ownerID = acc_prod_0;
			let itemState = 0;
			let created = await instance.oliveOilCreateItem(upc, productID, { from: acc_prod_0 });

			// Read the result from blockchain
			let res1 = await instance.fetcholiveOilItemBufferOne.call(upc);
			// console.log(res1, 'result buffer 1');

			assert.equal(res1.upc, upc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.productID, productID, 'Error: Missing or Invalid productID');
			assert.equal(res1.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(created, 'oliveOilCreated');
		});

		it('can the Producer blend a Olive Oil', async function () {
			this.timeout(20000);
			let oliveOilUpc = 1;
			let olivesUpc = 1;
			let productID = 1001;
			let ownerID = acc_prod_0;
			let itemState = 1;
			let blended = await instance.oliveOilBlendItem(oliveOilUpc, olivesUpc, { from: acc_prod_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchOliveOilItemBufferOne.call(oliveOilUpc);
			// console.log(res1, 'result buffer 1');
			// console.log(res1.olives, 'olives');

			assert.equal(res1.upc, oliveOilUpc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.productID, productID, 'Error: Missing or Invalid productID');
			assert.equal(res1.itemState, itemState, 'Error: Invalid item State');
			assert.equal(res1.olives[0], olivesUpc, 'Error: Invalid item olivesUpc');
			truffleAssert.eventEmitted(blended, 'Olive OilBlended');
		});

		it('can the Producer produce a Olive Oil', async function () {
			this.timeout(20000);
			let oliveOilUpc = 1;
			let productNotes = "Organic Olives Olive Oil";
			let productPrice = 26;
			let ownerID = acc_prod_0;
			let itemState = 2;
			let produced = await instance.oliveOilProduceItem(oliveOilUpc, productNotes, productPrice, { from: acc_prod_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchOliveOilItemBufferOne.call(oliveOilUpc);
			// console.log(res1, 'result buffer 1');
			// console.log(res1.olives, 'olives');

			assert.equal(res1.upc, oliveOilUpc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.productNotes, productNotes, 'Error: Missing or Invalid productNotes');
			assert.equal(res1.productPrice, productPrice, 'Error: Missing or Invalid productPrice');
			assert.equal(res1.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(produced, 'Olive OilProduced');
		});

		it('can the Inspector certify a Olive Oil', async function () {
			this.timeout(20000);
			let oliveOilUpc = 1;
			let certifyNotes = "ISO9002 Certified";
			let ownerID = acc_prod_0;
			let itemState = 3;
			let certified = await instance.oliveOilCertifyItem(oliveOilUpc, certifyNotes, { from: acc_insp_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchOliveOilItemBufferOne.call(oliveOilUpc);
			// console.log(res1, 'result buffer 1');
			// console.log(res1.olives, 'olives');

			assert.equal(res1.upc, oliveOilUpc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.certifyNotes, certifyNotes, 'Error: Missing or Invalid certifyNotes');
			assert.equal(res1.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(certified, 'Olive OilCertified');
		});

		it('can the Producer pack a Olive Oil', async function () {
			this.timeout(20000);
			let oliveOilUpc = 1;
			let ownerID = acc_prod_0;
			let itemState = 4;
			let packed = await instance.oliveOilPackItem(oliveOilUpc, { from: acc_prod_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchOliveOilItemBufferOne.call(oliveOilUpc);
			// console.log(res1, 'result buffer 1');
			// console.log(res1.olives, 'olives');

			assert.equal(res1.upc, oliveOilUpc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(packed, 'Olive OilPacked');
		});

		it('can the Distributor sell a Olive Oil', async function () {
			this.timeout(20000);
			let oliveOilUpc = 1;
			let ownerID = acc_prod_0;
			let itemState = 5;
			let forsale = await instance.oliveOilSellItem(oliveOilUpc, { from: acc_dist_0 });

			// Read the result from blockchain
			let res1 = await instance.fetchOliveOilItemBufferOne.call(oliveOilUpc);
			// console.log(res1, 'result buffer 1');
			// console.log(res1.olives, 'olives');

			assert.equal(res1.upc, oliveOilUpc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(forsale, 'Olive Oil ForSale');
		});

		it('can the Consumer buy a Olive Oil', async function () {
			this.timeout(20000);
			let Olive OilUpc = 1;
			let ownerID = acc_cons_0;
			let itemState = 6;
			let res1 = await instance.fetchOliveOilItemBufferOne.call(oliveOilUpc);
			let purchased = await instance.oliveOilBuyItem(oliveOilUpc, { from: acc_cons_0, value: res1.productPrice });

			// Read the result from blockchain
			res1 = await instance.fetchOliveOilItemBufferOne.call(oliveOilUpc);
			// console.log(res1, 'result buffer 1');
			// console.log(res1.olives, 'olives');

			assert.equal(res1.upc, oliveOilUpc, 'Error: Invalid item UPC');
			assert.equal(res1.ownerID, ownerID, 'Error: Missing or Invalid ownerID');
			assert.equal(res1.itemState, itemState, 'Error: Invalid item State');
			truffleAssert.eventEmitted(purchased, 'Olive OilPurchased');
		});
	});
});
