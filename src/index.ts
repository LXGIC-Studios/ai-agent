/**
 * ai-agent
 * AI agent framework scaffolding
 * 
 * @packageDocumentation
 */

import OpenAI from 'openai';
import { z } from 'zod';

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

// ============================================================================
// Types
// ============================================================================

export interface Tool {
  name: string;
  description: string;
  parameters: z.ZodType<any>;
  execute: (params: any) => Promise<string>;
}

export interface AgentConfig {
  name?: string;
  model?: string;
  systemPrompt?: string;
  tools?: Tool[];
  maxIterations?: number;
  verbose?: boolean;
}

export interface AgentStep {
  type: 'thought' | 'action' | 'observation' | 'final';
  content: string;
  toolName?: string;
  toolInput?: any;
}

export interface AgentResult {
  answer: string;
  steps: AgentStep[];
  iterations: number;
}

// ============================================================================
// Tool Helpers
// ============================================================================

export function defineTool<T extends z.ZodType<any>>(
  name: string,
  description: string,
  parameters: T,
  execute: (params: z.infer<T>) => Promise<string>
): Tool {
  return { name, description, parameters, execute };
}

function zodToJsonSchema(schema: z.ZodType<any>): any {
  if (schema instanceof z.ZodString) return { type: 'string' };
  if (schema instanceof z.ZodNumber) return { type: 'number' };
  if (schema instanceof z.ZodBoolean) return { type: 'boolean' };
  if (schema instanceof z.ZodOptional) {
    return zodToJsonSchema((schema as any)._def.innerType);
  }
  if (schema instanceof z.ZodObject) {
    const shape = (schema as any)._def.shape();
    const properties: Record<string, any> = {};
    const required: string[] = [];
    for (const [key, value] of Object.entries(shape)) {
      properties[key] = zodToJsonSchema(value as z.ZodType<any>);
      if (!(value instanceof z.ZodOptional)) required.push(key);
    }
    return { type: 'object', properties, required };
  }
  return { type: 'string' };
}

// ============================================================================
// ReAct Agent
// ============================================================================

export class ReActAgent {
  private config: Required<AgentConfig>;
  private tools: Map<string, Tool>;

  constructor(config: AgentConfig = {}) {
    this.config = {
      name: config.name || 'Agent',
      model: config.model || 'gpt-4-turbo',
      systemPrompt: config.systemPrompt || 'You are a helpful AI assistant.',
      tools: config.tools || [],
      maxIterations: config.maxIterations || 10,
      verbose: config.verbose || false,
    };

    this.tools = new Map();
    for (const tool of this.config.tools) {
      this.tools.set(tool.name, tool);
    }
  }

  async run(input: string): Promise<AgentResult> {
    const steps: AgentStep[] = [];
    const messages: OpenAI.ChatCompletionMessageParam[] = [
      { role: 'system', content: this.config.systemPrompt },
      { role: 'user', content: input },
    ];

    const openaiTools: OpenAI.ChatCompletionTool[] = this.config.tools.map(t => ({
      type: 'function',
      function: {
        name: t.name,
        description: t.description,
        parameters: zodToJsonSchema(t.parameters),
      },
    }));

    for (let i = 0; i < this.config.maxIterations; i++) {
      const response = await openai.chat.completions.create({
        model: this.config.model,
        messages,
        tools: openaiTools.length > 0 ? openaiTools : undefined,
        tool_choice: openaiTools.length > 0 ? 'auto' : undefined,
      });

      const message = response.choices[0].message;

      // Check for tool calls
      if (message.tool_calls && message.tool_calls.length > 0) {
        messages.push(message);

        for (const toolCall of message.tool_calls) {
          const tool = this.tools.get(toolCall.function.name);
          if (!tool) {
            throw new Error(`Unknown tool: ${toolCall.function.name}`);
          }

          const args = JSON.parse(toolCall.function.arguments);
          
          steps.push({
            type: 'action',
            content: `Calling ${toolCall.function.name}`,
            toolName: toolCall.function.name,
            toolInput: args,
          });

          if (this.config.verbose) {
            console.log(`[${this.config.name}] Action: ${toolCall.function.name}(${JSON.stringify(args)})`);
          }

          const result = await tool.execute(args);

          steps.push({
            type: 'observation',
            content: result,
            toolName: toolCall.function.name,
          });

          if (this.config.verbose) {
            console.log(`[${this.config.name}] Observation: ${result.slice(0, 100)}...`);
          }

          messages.push({
            role: 'tool',
            tool_call_id: toolCall.id,
            content: result,
          });
        }
      } else {
        // Final answer
        const answer = message.content || '';
        steps.push({ type: 'final', content: answer });

        if (this.config.verbose) {
          console.log(`[${this.config.name}] Final: ${answer.slice(0, 100)}...`);
        }

        return { answer, steps, iterations: i + 1 };
      }
    }

    throw new Error('Max iterations reached');
  }

  addTool(tool: Tool): void {
    this.tools.set(tool.name, tool);
    this.config.tools.push(tool);
  }
}

// ============================================================================
// Simple Agent (no tools)
// ============================================================================

export class SimpleAgent {
  private config: { model: string; systemPrompt: string };

  constructor(config: { model?: string; systemPrompt?: string } = {}) {
    this.config = {
      model: config.model || 'gpt-4-turbo',
      systemPrompt: config.systemPrompt || 'You are a helpful AI assistant.',
    };
  }

  async run(input: string): Promise<string> {
    const response = await openai.chat.completions.create({
      model: this.config.model,
      messages: [
        { role: 'system', content: this.config.systemPrompt },
        { role: 'user', content: input },
      ],
    });

    return response.choices[0].message.content || '';
  }
}

// ============================================================================
// Common Tools
// ============================================================================

export const calculatorTool = defineTool(
  'calculator',
  'Evaluate mathematical expressions',
  z.object({ expression: z.string().describe('Math expression to evaluate') }),
  async ({ expression }) => {
    try {
      const result = new Function(`return ${expression}`)();
      return String(result);
    } catch (e) {
      return `Error: Invalid expression`;
    }
  }
);

export const currentTimeTool = defineTool(
  'get_time',
  'Get the current date and time',
  z.object({}),
  async () => new Date().toISOString()
);

export const webSearchTool = defineTool(
  'web_search',
  'Search the web for information',
  z.object({ query: z.string().describe('Search query') }),
  async ({ query }) => {
    // Placeholder - implement with actual search API
    return `Search results for: ${query}\n(Implement with actual search API)`;
  }
);

// ============================================================================
// Factory
// ============================================================================

export function createAgent(config?: AgentConfig): ReActAgent {
  return new ReActAgent(config);
}

export function createSimpleAgent(config?: { model?: string; systemPrompt?: string }): SimpleAgent {
  return new SimpleAgent(config);
}
