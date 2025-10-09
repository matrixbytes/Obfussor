<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { EditorView, basicSetup } from 'codemirror';
  import { EditorState } from '@codemirror/state';
  import { cpp } from '@codemirror/lang-cpp';
  import { oneDark } from '@codemirror/theme-one-dark';

  export let code = '';
  export let readOnly = false;
  export let onChange: ((newCode: string) => void) | undefined = undefined;
  
  let editorContainer: HTMLDivElement;
  let view: EditorView;

  onMount(() => {
    const startState = EditorState.create({
      doc: code,
      extensions: [
        basicSetup,
        cpp(),
        oneDark,
        EditorView.editable.of(!readOnly),
        EditorView.updateListener.of((update) => {
          if (update.docChanged && onChange) {
            onChange(update.state.doc.toString());
          }
        }),
        EditorView.theme({
          '&': { height: '100%' },
          '.cm-scroller': { overflow: 'auto' }
        })
      ]
    });

    view = new EditorView({
      state: startState,
      parent: editorContainer
    });
  });

  onDestroy(() => {
    if (view) {
      view.destroy();
    }
  });

  export function setCode(newCode: string) {
    if (view) {
      view.dispatch({
        changes: { from: 0, to: view.state.doc.length, insert: newCode }
      });
    }
  }

  export function getCode(): string {
    return view ? view.state.doc.toString() : code;
  }
</script>

<div bind:this={editorContainer} class="editor-wrapper"></div>

<style>
  .editor-wrapper {
    height: 100%;
    width: 100%;
  }

  :global(.cm-editor) {
    height: 100%;
    font-size: 14px;
    font-family: 'JetBrains Mono', 'Fira Code', 'Consolas', monospace;
  }

  :global(.cm-scroller) {
    overflow: auto;
  }

  :global(.cm-gutters) {
    background-color: #252526;
    border-right: 1px solid #3e3e42;
  }
</style>