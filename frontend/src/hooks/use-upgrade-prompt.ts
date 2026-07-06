import { useState, useEffect, useCallback } from 'react';

export interface UpgradePromptData {
  message: string;
  resource: string;
  usage?: { current: number; limit: number };
}

export function useUpgradePrompt() {
  const [promptData, setPromptData] = useState<UpgradePromptData | null>(null);

  useEffect(() => {
    const handler = (e: Event) => {
      const detail = (e as CustomEvent<UpgradePromptData>).detail;
      setPromptData(detail);
    };
    window.addEventListener('upgrade-required', handler);
    return () => window.removeEventListener('upgrade-required', handler);
  }, []);

  const dismiss = useCallback(() => setPromptData(null), []);

  return { promptData, dismiss };
}
