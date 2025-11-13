{
  class_path: 'Generation',
  init_args: {
    eval_dataset: {
      class_path: 'HFGenerationDataset',
      init_args: {
        path: 'sbintuitions/aio-extended-answers',
        split: 'validation',
        reference_list_template: '{{ answers }}',
      },
    },
    prompt_template: {
      class_path: 'Jinja2PromptTemplate',
      init_args: {
        template: |||
          以下はタスクを説明する指示と、追加の背景情報を提供する入力の組み合わせです。要求を適切に満たす回答を書いてください。
          ### 指示
          質問に対する最適な答えを日本語で一言から一文程度で示してください。答えは必ず「答えは「<回答>」」の形式で出力し、閉じカギ括弧の前で生成を終了してください。

          ### 入力：
          質問：ワールドカップは何年に一度開催されるの？
          ### 回答：
          答えは「4年」

          ### 入力：
          質問：携帯電話の身体に与える影響は？
          ### 回答：
          答えは「発がん性リスクを高める可能性」

          ### 入力：
          質問：太陽はどの方角から昇る？
          ### 回答：
          答えは「東」

          ### 入力：
          質問：{{ question }}
          ### 回答：
          答えは「
        |||,
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
    gen_kwargs: { max_new_tokens: 128, stop_sequences: ['」', '<|return|>'], temperature: 1, top_p: 1, top_k: 0 },
    batch_size: 1,
  },
}
