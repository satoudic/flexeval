{
  class_path: 'ChatResponse',
  init_args: {
    eval_dataset: {
      class_path: 'HFChatDataset',
      init_args: {
        path: 'sbintuitions/aio-extended-answers',
        split: 'validation',
        reference_list_template: '{{ answers }}',
        input_template: 'examples/gpt-oss-evaluation/prompts/aio_chat_input.jinja',
      },
    },
    metrics: [
      {
        class_path: 'CharF1',
        init_args: {
          lm_output_processor: [
            { class_path: 'HarmonyFinalChannelExtractor' },
            { class_path: 'LastLineExtractor' },
            { class_path: 'AIONormalizer' },
          ],
          reference_processor: { class_path: 'AIONormalizer' },
        },
      },
      {
        class_path: 'ExactMatch',
        init_args: {
          lm_output_processor: [
            { class_path: 'HarmonyFinalChannelExtractor' },
            { class_path: 'LastLineExtractor' },
            { class_path: 'AIONormalizer' },
          ],
          reference_processor: { class_path: 'AIONormalizer' },
        },
      },
    ],
    // GPT-OSS-20B outputs Harmony-style analysis + final channel text, so we need
    // enough headroom to reach the final answer segment instead of truncating.
    gen_kwargs: { max_new_tokens: 1536, stop_sequences: ['<|return|>'], temperature: 0, top_p: 1, top_k: 0 },
    batch_size: 2,
  },
}
