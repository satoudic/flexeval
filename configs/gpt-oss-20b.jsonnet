local base_token_size = 512;
local multiple_tokens = 32;
{
  class_path: "VLLM",
  init_args: {
    model: "openai/gpt-oss-20b",
    model_kwargs: {
      enable_chunked_prefill: false,
      max_model_len: 131072,
    },
    model_limit_tokens: 131072,
    default_gen_kwargs: {
      temperature: 1,
      top_p: 1,
      top_k: 0,
      min_p: 0,
    },
  },
}
