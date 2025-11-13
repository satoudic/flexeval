from __future__ import annotations

from .base import StringProcessor


class HarmonyFinalChannelExtractor(StringProcessor):
    """Extract the final channel message from Harmony-formatted outputs.

    Harmony(=OpenAI Response Format) models often emit traces such as
    ``<|channel|>analysis<|message|>...<|end|><|start|>assistant<|channel|>final``.
    This processor returns the text that follows the final channel marker while
    stripping trailing special tokens like ``<|return|>``.
    If the marker is missing, the original text is returned.
    """

    FINAL_MARKER = "<|channel|>final<|message|>"
    TRAILING_TOKENS = ("<|return|>")

    def __call__(self, text: str) -> str:
        marker_index = text.rfind(self.FINAL_MARKER)
        if marker_index == -1:
            return text.strip()

        start = marker_index + len(self.FINAL_MARKER)
        final_segment = text[start:]
        for token in self.TRAILING_TOKENS:
            token_index = final_segment.find(token)
            if token_index != -1:
                final_segment = final_segment[:token_index]
                break

        return final_segment.strip()
