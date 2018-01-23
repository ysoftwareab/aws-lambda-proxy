import _ from 'lodash';
import aws from 'aws-sdk';

let awsLambda = new aws.Lambda();

export let makeLocalHandler = function({lambda: {mainFun, awsFunctionName}}) {
  return function(e, ctx = {}, cb = _.noop) {
    awsLambda.getFunctionConfiguration({
      FunctionName: awsFunctionName,
      Qualifier: '$LATEST'
    }, function(err, data) {
      if (err) {
        throw err;
      }

      ctx = _.defaultsDeep({
        env: data.Environment.Variables
      }, ctx);
      mainFun(e, ctx, cb);
    });
  };
};

export default makeLocalHandler;