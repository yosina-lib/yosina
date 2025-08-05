import { default as ts } from "typescript";
import type { CircledOrSquaredRecord, HyphensRecord, IVSSVSBaseRecord } from "./dataset";

export const emitJson = (data: unknown): ts.Expression => {
  if (typeof data === "undefined") {
    throw new Error("emitting undefined is not allowed");
  }
  if (typeof data === "object") {
    if (data === null) {
      return ts.factory.createNull();
    }
    if (Array.isArray(data)) {
      return ts.factory.createArrayLiteralExpression(data.map(emitJson));
    }
    if (
      data instanceof String ||
      data instanceof Symbol ||
      data instanceof Number ||
      data instanceof BigInt ||
      data instanceof Boolean
    ) {
      data = data.valueOf();
    } else {
      return ts.factory.createObjectLiteralExpression(
        Object.entries(data).map(([k, v]) =>
          ts.factory.createPropertyAssignment(ts.factory.createStringLiteral(k), emitJson(v)),
        ),
        true,
      );
    }
  }
  switch (typeof data) {
    case "symbol":
      return ts.factory.createCallExpression(ts.factory.createIdentifier("Symbol"), undefined, [
        ts.factory.createStringLiteral(data.toString()),
      ]);
    case "string":
      return ts.factory.createStringLiteral(data);
    case "number":
      return ts.factory.createNumericLiteral(data);
    case "bigint":
      return ts.factory.createBigIntLiteral(data.toString());
    case "boolean":
      return data ? ts.factory.createTrue() : ts.factory.createFalse();
    default:
      throw new Error(`should never get here: ${data}`);
  }
};

type Mutable<T> = { -readonly [P in keyof T]: T[P] };

const makeMutable = <T>(src: T): Mutable<T> => src as Mutable<T>;

const inheritText = (src: ts.SourceFile, modified: ts.SourceFile): ts.SourceFile => {
  const result = makeMutable(modified);
  result.pos = src.pos;
  result.end = src.end;
  result.text = src.text;
  return result;
};

const renderTransliterator = (template: ts.SourceFile, data: unknown) =>
  inheritText(
    template,
    ts.factory.createSourceFile(
      template.statements.map((node) => {
        if (ts.isVariableStatement(node)) {
          return ts.setTextRange(
            ts.factory.createVariableStatement(
              node.modifiers,
              ts.factory.createVariableDeclarationList(
                node.declarationList.declarations.map((m) =>
                  ts.isVariableDeclaration(m) && m.name.getText(template) === "mappings"
                    ? ts.factory.createVariableDeclaration(m.name, m.exclamationToken, m.type, emitJson(data))
                    : m,
                ),
                node.declarationList.flags,
              ),
            ),
            node,
          );
        }

        if (ts.isTypeAliasDeclaration(node)) {
          if (node.name.text === "Char") {
            return ts.setTextRange(
              ts.factory.createImportDeclaration(
                [],
                ts.factory.createImportClause(
                  true,
                  undefined,
                  ts.factory.createNamedImports([ts.factory.createImportSpecifier(false, undefined, node.name)]),
                ),
                ts.factory.createStringLiteral("../types.ts"),
              ),
              node,
            );
          }
        }

        return node;
      }),
      template.endOfFileToken as ts.EndOfFileToken,
      template.flags,
    ),
  );

export const renderSimpleTransliterator = (template: ts.SourceFile, data: [string, string][]) =>
  renderTransliterator(template, Object.fromEntries(data));

export const renderHyphensTransliterator = (template: ts.SourceFile, data: [string, HyphensRecord][]) =>
  renderTransliterator(template, Object.fromEntries(data));

const buildCompressedIVSSVSBaseRecords = (data: IVSSVSBaseRecord[]): string =>
  data.flatMap((r) => [r.ivs ?? "\0", r.svs ?? "\0", r.base90 ?? "\0", r.base2004 ?? "\0"]).join("");

export const renderIVSSVSVBaseTransliterator = (template: ts.SourceFile, data: IVSSVSBaseRecord[]) =>
  renderTransliterator(template, buildCompressedIVSSVSBaseRecords(data));

export const renderMultiCharsTransliterator = (template: ts.SourceFile, data: [string, string[]][]) =>
  renderTransliterator(template, Object.fromEntries(data));

const buildCircledOrSquaredRecords = (data: [string, CircledOrSquaredRecord][]) =>
  Object.fromEntries(data.map(([key, record]) => [key, [record.rendering.join(""), record.type[0], record.emoji]]));

export const renderCircledOrSquaredTransliterator = (
  template: ts.SourceFile,
  data: [string, CircledOrSquaredRecord][],
) => renderTransliterator(template, buildCircledOrSquaredRecords(data));
