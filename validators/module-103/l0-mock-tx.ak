use aiken/dict
use aiken/interval
use aiken/transaction.{
  Mint, OutputReference, ScriptContext, Spend, Transaction, TransactionId,
  placeholder,
}
use aiken/transaction/value
use mocktail.{complete, mocktail_tx}
use mocktail/virgin_output_reference.{mock_utxo_ref}

/// Learning objective
/// 1. Get a basic understanding of transaction
/// 2. Understand that for every single smart contract validator, it has local access to entire current transaction
/// 3. Learn the Cardano type of utxo: txhash + txindex
/// 4. Learn about vodka mocktail util function: mock_utxo_ref
fn transaction_placeholder() -> Transaction {
  Transaction {
    inputs: [],
    reference_inputs: [],
    outputs: [],
    fee: value.zero(),
    mint: value.zero() |> value.to_minted_value(),
    certificates: [],
    withdrawals: [],
    validity_range: interval.everything(),
    extra_signatories: [],
    redeemers: [],
    datums: dict.new(),
    id: TransactionId {
      hash: #"0000000000000000000000000000000000000000000000000000000000000000",
    },
  }
}

test m103_l0_aiken_builtin_placeholder() {
  transaction_placeholder() == placeholder()
}

test m103_l0_aiken_mocktail_tx() {
  let tx = mocktail_tx() |> complete()
  placeholder() == tx
}

validator {
  fn always_succeed_minting_policy(_redeemer: Data, _context: ScriptContext) {
    True
  }
}

test m103_l0_test_always_succeed_minting_policy() {
  let redeemer = Void
  let context = ScriptContext { purpose: Mint(""), transaction: placeholder() }
  always_succeed_minting_policy(redeemer, context)
}

validator {
  fn always_succeed_spending_validator(
    _datum: Data,
    _redeemer: Data,
    _context: ScriptContext,
  ) {
    True
  }
}

test m103_l0_test_always_succeed_spending_validator() {
  let redeemer = Void
  let datum = Void

  let context =
    ScriptContext {
      purpose: Spend(
        OutputReference {
          transaction_id: TransactionId(
            #"580a225baee136641ba78acdc9a9b0537468db40acad46554834687ff5c18dd0",
          ),
          output_index: 0,
        },
      ),
      transaction: placeholder(),
    }
  always_succeed_spending_validator(datum, redeemer, context)
}

test m103_l0_mocktail_mock_utxo_ref() {
  mock_utxo_ref(0, 0) == OutputReference {
    transaction_id: TransactionId(
      #"580a225baee136641ba78acdc9a9b0537468db40acad46554834687ff5c18dd0",
    ),
    output_index: 0,
  }
}
