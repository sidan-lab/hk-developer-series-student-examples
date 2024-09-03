use aiken/transaction.{
  InlineDatum, ScriptContext, Spend, Transaction, find_input,
}
use aiken/transaction/value.{from_lovelace}
use mocktail.{
  complete, mocktail_tx, tx_in, tx_in_inline_datum, tx_out, tx_out_inline_datum,
}
use mocktail/virgin_address.{mock_script_address}
use mocktail/virgin_output_reference.{mock_tx_hash, mock_utxo_ref}
use vodka_inputs.{inputs_at}
use vodka_outputs.{outputs_at}

type Datum {
  Initialize
  ActiveTransition { count: Int }
}

type Redeemer {
  IncrementCount
  CloseState
}

/// 1. Familiar in the state channel pattern of Cardano development
///    - find current utxo validating
///    - check only 1 input and output from same address with updated datum
/// 2. Can distinguish between: the smart contract updates the datum vs the script validate if datum is updated -> building early concept on cardano validator
/// 3. Understand that the script might not be performed as imagined - starter can start with ending datum
validator {
  fn state_change_spending_validator(
    datum: Datum,
    redeemer: Redeemer,
    context: ScriptContext,
  ) {
    let ScriptContext { transaction, purpose } = context
    let Transaction { inputs, outputs, .. } = transaction
    expect Spend(utxo_ref) = purpose
    expect Some(own_input) = find_input(inputs, utxo_ref)
    let own_address = own_input.output.address

    when redeemer is {
      IncrementCount ->
        when
          (inputs_at(inputs, own_address), outputs_at(outputs, own_address))
        is {
          ([only_input], [only_output]) -> {
            expect InlineDatum(input_raw_datum) = only_input.output.datum
            expect InlineDatum(output_raw_datum) = only_output.datum
            expect input_datum: Datum = input_raw_datum
            expect output_datum: Datum = output_raw_datum
            let is_datum_updated =
              when input_datum is {
                Initialize -> output_datum == ActiveTransition { count: 1 }
                ActiveTransition { count } ->
                  output_datum == ActiveTransition { count: count + 1 }
              }
            is_datum_updated?
          }
          _ -> False
        }

      CloseState ->
        when datum is {
          ActiveTransition { count } -> count >= 10
          _ -> False
        }
    }
  }
}

type IncrementTestCase {
  is_only_one_script_input: Bool,
  is_only_one_script_output: Bool,
  is_current_datum_initialize: Bool,
  is_datum_updated: Bool,
}

fn mock_increment_tx(test_case: IncrementTestCase) -> Transaction {
  let IncrementTestCase {
    is_only_one_script_input,
    is_only_one_script_output,
    is_current_datum_initialize,
    is_datum_updated,
  } = test_case
  let (input_datum, output_count) =
    if is_current_datum_initialize {
      (Initialize, 1)
    } else {
      (ActiveTransition { count: 1 }, 2)
    }
  let output_datum =
    if is_datum_updated {
      ActiveTransition { count: output_count }
    } else {
      ActiveTransition { count: output_count - 1 }
    }

  mocktail_tx()
    |> tx_in(
        True,
        mock_tx_hash(0),
        0,
        from_lovelace(1_000_000),
        mock_script_address(0, None),
      )
    |> tx_in_inline_datum(True, input_datum)
    |> tx_in(
        !is_only_one_script_input,
        mock_tx_hash(0),
        0,
        from_lovelace(1_000_000),
        mock_script_address(0, None),
      )
    |> tx_in_inline_datum(!is_only_one_script_input, input_datum)
    |> tx_out(True, mock_script_address(0, None), from_lovelace(1_000_000))
    |> tx_out_inline_datum(True, output_datum)
    |> tx_out(
        !is_only_one_script_output,
        mock_script_address(0, None),
        from_lovelace(1_000_000),
      )
    |> tx_out_inline_datum(!is_only_one_script_output, output_datum)
    |> complete()
}

test m203_l4_test_increment_success_at_initialization() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_increment_tx(
        IncrementTestCase {
          is_only_one_script_input: True,
          is_only_one_script_output: True,
          is_current_datum_initialize: True,
          is_datum_updated: True,
        },
      ),
    }
  state_change_spending_validator(Initialize, IncrementCount, context)
}

test m203_l4_test_increment_success_at_active_transition() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_increment_tx(
        IncrementTestCase {
          is_only_one_script_input: True,
          is_only_one_script_output: True,
          is_current_datum_initialize: False,
          is_datum_updated: True,
        },
      ),
    }
  state_change_spending_validator(Initialize, IncrementCount, context)
}

test m203_l4_test_increment_fail_with_wrong_datum_1() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_increment_tx(
        IncrementTestCase {
          is_only_one_script_input: True,
          is_only_one_script_output: True,
          is_current_datum_initialize: True,
          is_datum_updated: False,
        },
      ),
    }
  !state_change_spending_validator(Initialize, IncrementCount, context)
}

test m203_l4_test_increment_fail_with_wrong_datum_2() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_increment_tx(
        IncrementTestCase {
          is_only_one_script_input: True,
          is_only_one_script_output: True,
          is_current_datum_initialize: False,
          is_datum_updated: False,
        },
      ),
    }
  !state_change_spending_validator(Initialize, IncrementCount, context)
}

test m203_l4_test_increment_fail_with_multiple_script_inputs() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_increment_tx(
        IncrementTestCase {
          is_only_one_script_input: False,
          is_only_one_script_output: True,
          is_current_datum_initialize: True,
          is_datum_updated: True,
        },
      ),
    }
  !state_change_spending_validator(Initialize, IncrementCount, context)
}

test m203_l4_test_increment_fail_with_multiple_script_outputs() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_increment_tx(
        IncrementTestCase {
          is_only_one_script_input: True,
          is_only_one_script_output: False,
          is_current_datum_initialize: True,
          is_datum_updated: True,
        },
      ),
    }
  !state_change_spending_validator(Initialize, IncrementCount, context)
}

type CloseStateTestCase {
  is_count_sufficient: Bool,
}

fn mock_close_state_tx(test_case: CloseStateTestCase) -> Transaction {
  let CloseStateTestCase { is_count_sufficient } = test_case
  let count =
    if is_count_sufficient {
      11
    } else {
      10
    }

  mocktail_tx()
    |> tx_in(
        True,
        mock_tx_hash(0),
        0,
        from_lovelace(1_000_000),
        mock_script_address(0, None),
      )
    |> tx_in_inline_datum(True, ActiveTransition { count })
    |> complete()
}

test m203_l4_test_close_state_success() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_close_state_tx(
        CloseStateTestCase { is_count_sufficient: True },
      ),
    }
  state_change_spending_validator(
    ActiveTransition { count: 10 },
    CloseState,
    context,
  )
}

test m203_l4_test_close_state_fail_with_insufficient_count() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_close_state_tx(
        CloseStateTestCase { is_count_sufficient: False },
      ),
    }
  !state_change_spending_validator(
    ActiveTransition { count: 9 },
    CloseState,
    context,
  )
}
