{
  class_path: 'ChatResponse',
  init_args: {
    eval_dataset: {
      class_path: 'HFChatDataset',
      init_args: {
        path: 'sbintuitions/JEMHopQA',
        subset: 'v1.1',
        reference_template: '{{ answer }}',
        split: 'validation',
        keep_conditions: { "{{ time_dependent }}": "False" },
        input_template: 'examples/gpt-oss-evaluation/prompts/jemhopqa_chat_input.jinja',
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
    gen_kwargs: {
      max_new_tokens: 256,
      temperature: 1,
      top_p: 1,
      top_k: 0,
      stop_sequences: ['<|return|>'],
    },
    batch_size: 2,
  },
}
