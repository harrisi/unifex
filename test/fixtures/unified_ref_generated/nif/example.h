#pragma once

#include "../../example.h"
#include <erl_nif.h>
#include <stdint.h>
#include <stdio.h>
#include <unifex/payload.h>
#include <unifex/unifex.h>

#ifdef __cplusplus
extern "C" {
#endif

#define UNIFEX_MODULE "Elixir.Example"

/*
 * Functions that manage lib and state lifecycle
 * Functions with 'unifex_' prefix are generated automatically,
 * the user have to implement rest of them.
 */

/*
 * Declaration of native functions for module Elixir.Example.
 * The implementation have to be provided by the user.
 */

UNIFEX_TERM foo(UnifexEnv *env);

/*
 * Callbacks for nif lifecycle hooks.
 * Have to be implemented by user.
 */

/*
 * Functions that create the defined output from Nif.
 * They are automatically generated and don't need to be implemented.
 */

UNIFEX_TERM foo_result_ok(UnifexEnv *env, int answer);

/*
 * Functions that send the defined messages from Nif.
 * They are automatically generated and don't need to be implemented.
 */

#ifdef __cplusplus
}
#endif
