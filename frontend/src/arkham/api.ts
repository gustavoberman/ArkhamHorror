import api from '@/api';
import { gameDecoder } from '@/arkham/types/Game';
import { deckDecoder } from '@/arkham/types/Deck';
import { Difficulty } from '@/arkham/types/Difficulty';
import { Message } from '@/arkham/types/Message';
import { JsonDecoder } from 'ts.data.json';

export const fetchGame = (gameId: string) => api
  .get(`arkham/games/${gameId}`)
  .then((resp) => {
    const { investigatorId, game } = resp.data;
    return gameDecoder
      .decodePromise(game)
      .then((gameData) => Promise.resolve({ investigatorId, game: gameData }));
  });

export const fetchGames = () => api
  .get('arkham/games')
  .then((resp) => JsonDecoder.array(gameDecoder, 'ArkhamGame[]').decodePromise(resp.data));

export const fetchDecks = () => api
  .get('arkham/decks')
  .then((resp) => JsonDecoder.array(deckDecoder, 'ArkhamDeck[]').decodePromise(resp.data));

export const newDeck = (
  deckId: string,
  deckName: string,
  deckUrl: string,
) => api
  .post('arkham/decks', {
    deckId,
    deckName,
    deckUrl,
  })
  .then((resp) => deckDecoder.decodePromise(resp.data));

export const deleteDeck = (deckId: string) => api
  .delete(`arkham/decks/${deckId}`);

export const updateGame = (gameId: string, choice: number) => api
  .put(`arkham/games/${gameId}`, { choice })

export const upgradeDeck = (gameId: string, deckUrl?: string) => api
  .put(`arkham/games/${gameId}/decks`, { deckUrl });

export const deleteGame = (gameId: string) => api
  .delete(`arkham/games/${gameId}`);

export const fetchGameRaw = (gameId: string) => api
  .get(`arkham/games/${gameId}`)
  .then((resp) => resp.data);

export const updateGameRaw = (gameId: string, gameJson: string, gameMessage: Message | null) => api
  .put(`arkham/games/${gameId}/raw`, { gameJson, gameMessage });

export const newGame = (
  deckId: string,
  playerCount: number,
  campaignId: string | null,
  scenarioId: string | null,
  difficulty: Difficulty,
  campaignName: string,
) => api
  .post('arkham/games', {
    deckId,
    playerCount,
    campaignId,
    scenarioId,
    difficulty,
    campaignName,
  })
  .then((resp) => gameDecoder.decodePromise(resp.data));

export const joinGame = (gameId: string, deckId: string) => api
  .put(`arkham/games/${gameId}/join`, { deckId })
  .then((resp) => gameDecoder.decodePromise(resp.data));

export const undoChoice = (gameId: string) => api
  .put(`arkham/games/${gameId}/undo`)
