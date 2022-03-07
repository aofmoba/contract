const TimeLock = artifacts.require("TimeLock")
const CYT = artifacts.require("CyberPopToken")
const { time, expectRevert, snapshot } = require("@openzeppelin/test-helpers");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");

contract("TimeLock", function (accounts) {
  let snapshotA
  let cyt
  let timelock

  beforeEach(async () => {
    cyt = await CYT.deployed()
    timelock = await TimeLock.deployed()
    snapshotA = await snapshot()
  })

  afterEach(async () => {
    await snapshotA.restore()
  })

  it("mints and lock for specified period", async function () {
    let userA = accounts[1]
    let userB = accounts[2]

    let batchPeriod = await timelock.BATCH_PERIOD()
    let batches = 10
    // start releasing in one year
    let lockPeriod = batchPeriod.toNumber() * 12
    let now = (await web3.eth.getBlock()).timestamp
    let due = Math.floor(Date.now() / 1000) + lockPeriod
    // lock up 10 CYT
    let amount = 10_000_000
    await timelock.lock(userA, amount, lockPeriod, batches)

    let balance = await cyt.balanceOf(timelock.address)
    assert.equal(balance.toNumber(), amount)

    await timelock.lock(userB, amount, lockPeriod, batches)
    let totalLocked = await timelock.totalLocked()

    assert.equal(totalLocked.toNumber(), amount * 2)

    let locker = await timelock.lockedBalances(userA)
    assert.equal(locker.releaseBatches, batches)
    assert.equal(locker.lockedAmount, amount)

    assert.equal(locker.lockTimestamp.toNumber(), due)
    // assert within 20 seconds
    assert.isTrue(locker.lockTimestamp.toNumber() >= due && locker.lockTimestamp.toNumber() <= due + 100)

    // assert cannot change lock time
    await expectRevert(timelock.lock(userA, amount, lockPeriod, batches), "CYT Locker: cannot re-lock a locked address")
  })

  it("allows withdraw only after lock period", async function () {
    let userA = accounts[3]
    let userB = accounts[4]

    let batchPeriod = await timelock.BATCH_PERIOD()
    let batches = 5
    // release time in 10 months
    let lockPeriod = batchPeriod.toNumber() * 10
    let now = (await web3.eth.getBlock()).timestamp
    let due = Math.floor(Date.now() / 1000) + lockPeriod

    // lock up 10 CYT
    let amount = 10_000_000
    await timelock.lock(userA, amount, lockPeriod, batches)

    await expectRevert(timelock.withdraw({ from: userA }), "CYT Locker: lock duration not passed")
    // Cannot withdraw if there is no balance
    await expectRevert(timelock.withdraw({ from: userB }), "CYT Locker: insufficient balance")

    let released = await timelock.releasedAmount(userA)

    await time.increaseTo(due + 100)
    released = await timelock.releasedAmount(userA)

    // release first batch
    await timelock.withdraw({ from: userA })
    let balance = await cyt.balanceOf(userA)
    assert.equal(balance.toNumber(), amount / batches)

    // release second batch
    await time.increase(batchPeriod)
    await timelock.withdraw({ from: userA })
    balance = await cyt.balanceOf(userA)
    assert.equal(balance.toNumber(), (amount / batches) * 2)

    // release all batches
    await time.increase(batchPeriod * batches) // way over

    await timelock.withdraw({ from: userA })
    balance = await cyt.balanceOf(userA)
    // balance should not exceed locked amount
    assert.equal(balance.toNumber(), amount)
  })
})
