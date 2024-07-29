use aiken/list
use aiken/transaction.{
  Input, NoDatum, Output, OutputReference, ScriptContext, Spend, Transaction,
  placeholder,
}
use aiken/transaction/credential.{Address, VerificationKeyCredential}
use aiken/transaction/value
use sidan_placeholder/output_reference.{mock_utxo_ref}

/// Learning objecting
/// 1. Parameterizing script
/// 3. Familiar with property accessing for a type from transaction
/// 4. Familiar with control flow
validator(utxo: OutputReference) {
  fn always_succeed_minting_policy(_redeemer: Data, context: ScriptContext) {
    let inputs = context.transaction.inputs
    when list.find(inputs, fn(input) { input.output_reference == utxo }) is {
      Some(_) -> True
      _ -> False
    }
  }
}

test m103_l2_test_one_time_minting_policy() {
  let redeemer = Void

  let input =
    Input {
      output_reference: mock_utxo_ref(0, 0),
      output: Output {
        address: Address {
          payment_credential: VerificationKeyCredential(""),
          stake_credential: None,
        },
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }

  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: Transaction { ..placeholder(), inputs: [input] },
    }

  always_succeed_minting_policy(mock_utxo_ref(0, 0), redeemer, context)
}
