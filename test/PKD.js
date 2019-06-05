// eslint-disable-next-line no-undef
const PKD = artifacts.require('PKD');

let nameInput;
let whisperPublicKeyInput;
let zkpPublicKeyInput;

// eslint-disable-next-line no-undef
contract('PKD', accounts => {
  let pkd;

  before(async () => {
    pkd = await PKD.new();
    // eslint-disable-next-line no-undef
    nameInput = web3.utils.utf8ToHex(`duncan${Date.now()}`);
  });

  it('Name can be set and retrieved using the PKD name to address association', async () => {
    await pkd.setName(nameInput);
    const nameFromAddress = await pkd.getNameFromAddress(accounts[0]);
    const addressFromName = await pkd.getAddressFromName(nameInput);

    // eslint-disable-next-line no-undef
    assert.equal(accounts[0].toLowerCase(), addressFromName.toLowerCase());
    // eslint-disable-next-line no-undef
    assert.equal(nameInput, nameFromAddress.slice(0, 40));
  });

  it('Presence of names can be checked if it was previously registered or not', async () => {
    const checkName = await pkd.isNameInUse(nameInput);
    // eslint-disable-next-line no-undef
    assert.equal(checkName, true);
  });

  it('Registered name is in the list of pre-registered names', async () => {
    const nameList = await pkd.getNames();

    if (nameList.length === 1) {
      // eslint-disable-next-line no-undef
      assert.equal(nameList[0].slice(0, 40), nameInput);
    } else {
      // eslint-disable-next-line no-undef
      assert.include(nameList, nameInput);
    }
  });

  it('Whisper public key can be set and retrieved using the PKD whisper public key to address association', async () => {
    whisperPublicKeyInput =
      '0x04f39b93e3c7968df4358e17222adc0cd8a12d24f94ad63d3cb5abf536381bca4234af17102338638ab40cec85cffe9a021f699e2c84064c492f3f4442a1f147eb';
    await pkd.setWhisperPublicKey(whisperPublicKeyInput);
    const whisperPublicKeyOutput = await pkd.getWhisperPublicKeyFromAddress(accounts[0]);
    // eslint-disable-next-line no-undef
    assert.equal(whisperPublicKeyInput, whisperPublicKeyOutput);
  });

  it('Whisper public key can be set and retrieved using the PKD whisper public key to name association', async () => {
    const nameFromAddress = await pkd.getNameFromAddress(accounts[0]);
    const whisperPublicKeyOutput = await pkd.getWhisperPublicKeyFromName(nameFromAddress);
    // eslint-disable-next-line no-undef
    assert.equal(whisperPublicKeyInput, whisperPublicKeyOutput);
  });

  it('ZKP public key can be set and retrieved using the ZKP public key to address association', async () => {
    // eslint-disable-next-line no-undef
    zkpPublicKeyInput = await web3.utils.randomHex(27);
    await pkd.setZkpPublicKey(zkpPublicKeyInput);
    const zkpPublicKeyOutput = await pkd.getZkpPublicKeyFromAddress(accounts[0]);
    // eslint-disable-next-line no-undef
    assert.equal(zkpPublicKeyInput, zkpPublicKeyOutput);
  });

  it('ZKP public key can be set and retrieved using the ZKP public key to name association', async () => {
    const nameFromAddress = await pkd.getNameFromAddress(accounts[0]);
    const zkpPublicKeyOutput = await pkd.getZkpPublicKeyFromName(nameFromAddress);
    // eslint-disable-next-line no-undef
    assert.equal(zkpPublicKeyInput, zkpPublicKeyOutput);
  });

  it('Public key can be set and retrieved using the Public key to address association', async () => {
    // eslint-disable-next-line no-undef
    zkpPublicKeyInput = await web3.utils.randomHex(27);

    const publicKeyInput = [];
    const publicKeyOutput = [];

    publicKeyInput.push(whisperPublicKeyInput, zkpPublicKeyInput);

    await pkd.setPublicKeys(whisperPublicKeyInput, zkpPublicKeyInput);

    const rawPublicKeyOutput = await pkd.getPublicKeysFromAddress(accounts[0]);
    publicKeyOutput[0] = rawPublicKeyOutput.whisperPublicKey;
    publicKeyOutput[1] = rawPublicKeyOutput.zkpPublicKey;
    // eslint-disable-next-line no-undef
    assert.deepEqual(publicKeyOutput, publicKeyInput);
  });

  it('Public key can be set and retrieved using the Public key to name association', async () => {
    const publicKeyInput = [];
    const publicKeyOutput = [];

    publicKeyInput.push(whisperPublicKeyInput, zkpPublicKeyInput);

    const nameFromAddress = await pkd.getNameFromAddress(accounts[0]);
    const rawPublicKeyOutput = await pkd.getPublicKeysFromName(nameFromAddress);
    publicKeyOutput[0] = rawPublicKeyOutput.whisperPublicKey;
    publicKeyOutput[1] = rawPublicKeyOutput.zkpPublicKey;
    // eslint-disable-next-line no-undef
    assert.deepEqual(publicKeyOutput, publicKeyInput);
  });
});
