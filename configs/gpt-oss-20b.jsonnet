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
    system_message: "あなたはクイズ回答に特化したアシスタントです。与えられた指示に従い、思考過程や余計な会話を出力せず、日本語で『答えは「<回答>」』の形だけを最終チャンネルに返してください。",
    default_gen_kwargs: {
      temperature: 1,
      top_p: 1,
      top_k: 0,
      min_p: 0,
    },
  },
}
