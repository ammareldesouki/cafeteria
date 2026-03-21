// Simple console-based logger replacement (no external logging libraries)

type LogLevel = 'debug' | 'info' | 'warn' | 'error';

const baseLogger = {
  debug: (...args: unknown[]) => console.debug('[DEBUG]', ...args),
  info: (...args: unknown[]) => console.info('[INFO]', ...args),
  warn: (...args: unknown[]) => console.warn('[WARN]', ...args),
  error: (...args: unknown[]) => console.error('[ERROR]', ...args),
};

export const logger: Record<LogLevel, (...args: unknown[]) => void> = baseLogger;

// morgan stream-compatible writer
export const stream = { write: (msg: string) => logger.info(msg.trim()) };
