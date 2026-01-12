import ldes from './ldes';
import modified from './modified';
import politiezones from './politiezones';
import decisions from './decisions';
import devRules from './core-dev';
import prodRules from './core';

const useDevRules = process.env.USE_DEV_RULES === 'true';

const rules = [];
if (useDevRules) {
  console.log('Using DEV delta rules');
  rules.push(...devRules);
} else {
  console.log('Using PROD delta rules');
  rules.push(...prodRules);
}

rules.push(...ldes);
rules.push(...decisions);
rules.push(...modified);
rules.push(...politiezones);

export default rules;
