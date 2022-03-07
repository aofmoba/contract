const TimeLock = artifacts.require("TimeLock")
const CYT = artifacts.require("CyberPopToken")
const { time, expectRevert } = require("@openzeppelin/test-helpers");

contract("TimeLock", function (accounts) {
  it("mints and lock for specified period", async function () {
    let cyt = await CYT.deployed()
    let timelock = await TimeLock.deployed()

    let userA = accounts[1]
    let userB = accounts[2]

    // release time
    let due = new Date().getMilliseconds() + 60 * 1000
    // lock up 10 CYT
    let amount = 10_000_000
    await timelock.lock(userA, amount, due)

    let balance = await cyt.balanceOf(timelock.address)
    assert.equal(balance.toNumber(), amount)

    await timelock.lock(userB, amount, due)
    let totalLocked = await timelock.totalLocked()

    assert.equal(totalLocked.toNumber(), amount * 2)

    let locker = await timelock.lockedBalances(userA)
    assert.equal(locker.lockTimestamp, due)
    assert.equal(locker.lockedAmount, amount)

    // assert cannot change lock time
    await expectRevert(timelock.lock(userA, amount, due), "CYT Locker: cannot re-lock a locked address")
  })

  it("allows withdraw only after lock period", async function () {
    let cyt = await CYT.deployed()
    let timelock = await TimeLock.deployed()

    let userA = accounts[3]
    let userB = accounts[4]
    console.log("userA: " + userA)
    console.log("userB: " + userB)

    // lock period
    let lockPeriod = 60
    // lock up 10 CYT
    let amount = 10_000_000
    await timelock.lock(userA, amount, lockPeriod, 10)

    await expectRevert(timelock.withdraw(amount, { from: userA }), "CYT Locker: lock duration not passed")
    // Cannot withdraw if there is no balance
    await expectRevert(timelock.withdraw(amount, { from: userB }), "CYT Locker: insufficient balance")

    let locker = await timelock.lockedBalances(userA)
    //assert.equal(locker.lockTimestamp, due)
    console.log(locker.lockedAmount)


    await time.increase(60 + 1)
    // await timelock.withdraw(amount, { from: userA })
    let balance = await cyt.balanceOf(userA)
    assert.equal(balance.toNumber(), amount)
  })
})
