.PHONY: render-diagrams

# docs/diagrams/*.mmd を変更した後は必ずこのコマンドを実行し、生成された SVG を一緒にコミットすること
render-diagrams:
	/bin/zsh -lc 'npx --yes @mermaid-js/mermaid-cli -i docs/diagrams/er.mmd -o docs/diagrams/er.svg'
