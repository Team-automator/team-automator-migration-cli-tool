module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);

  root
    .find(j.CallExpression, {
      callee: { name: "createRoot" },
      arguments: [
        {
          type: "CallExpression",
          callee: {
            object: { name: "document" },
            property: { name: "getElementById" },
          },
        },
      ],
    })
    .forEach((path) => {
      const originalCall = path.node.arguments[0];

      // Wrap the getElementById(...) call in a non-null assertion
      const nonNullAsserted = j.tsNonNullExpression(originalCall);

      // Replace the argument with the asserted version
      path.node.arguments[0] = nonNullAsserted;
    });

  return root.toSource({ quote: "single" });
};
