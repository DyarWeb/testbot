<?php


namespace App\BotHandlers;

use WeStacks\TeleBot\Handlers\UpdateHandler;

class SearchMoviesInlineQuery extends UpdateHandler
{
    /**
     * @inheritDoc
     */
    public function trigger(): bool
    {
        return isset($this->update->inline_query);
    }

    public function handle()
    {
        $results[] = [
            'id' => 'test',
            'type' => 'article',
            'title' => 'test',
            'input_message_content' => ['message_text' => 'test']
        ];
        $this->answerInlineQuery([
            'inline_query_id' => $this->update->inline_query->id,
            'results' => $results,
            'cache_time' => 0
        ]);
    }
}
