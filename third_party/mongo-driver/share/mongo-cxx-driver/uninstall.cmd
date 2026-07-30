@echo off

REM MongoDB C++ Driver uninstall program, generated with CMake
REM
REM Copyright 2009-present MongoDB, Inc.
REM
REM Licensed under the Apache License, Version 2.0 (the "License");
REM you may not use this file except in compliance with the License.
REM You may obtain a copy of the License at
REM
REM   http://www.apache.org/licenses/LICENSE-2.0
REM
REM Unless required by applicable law or agreed to in writing, software
REM distributed under the License is distributed on an "AS IS" BASIS,
REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM See the License for the specific language governing permissions and
REM limitations under the License.



REM Windows does not handle a batch script deleting itself during
REM execution.  Copy the uninstall program into the TEMP directory from
REM the environment and run from there so everything in the installation
REM is deleted and the copied program deletes itself at the end.
if /i "%~dp0" NEQ "%TEMP%\" (
   copy "%~f0" "%TEMP%\mongoc-%~nx0" >NUL
   "%TEMP%\mongoc-%~nx0" & del "%TEMP%\mongoc-%~nx0"
)

pushd D:\gptwork\RubbageChat\third_party\mongo-driver\

echo Removing file include\bsoncxx\v1\array\value-fwd.hpp
del include\bsoncxx\v1\array\value-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\array\value.hpp
del include\bsoncxx\v1\array\value.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\array\view-fwd.hpp
del include\bsoncxx\v1\array\view-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\array\view.hpp
del include\bsoncxx\v1\array\view.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\decimal128-fwd.hpp
del include\bsoncxx\v1\decimal128-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\decimal128.hpp
del include\bsoncxx\v1\decimal128.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\detail\bit.hpp
del include\bsoncxx\v1\detail\bit.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\detail\compare.hpp
del include\bsoncxx\v1\detail\compare.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\detail\macros.hpp
del include\bsoncxx\v1\detail\macros.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\detail\postlude.hpp
del include\bsoncxx\v1\detail\postlude.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\detail\prelude.hpp
del include\bsoncxx\v1\detail\prelude.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\detail\type_traits.hpp
del include\bsoncxx\v1\detail\type_traits.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\document\value-fwd.hpp
del include\bsoncxx\v1\document\value-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\document\value.hpp
del include\bsoncxx\v1\document\value.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\document\view-fwd.hpp
del include\bsoncxx\v1\document\view-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\document\view.hpp
del include\bsoncxx\v1\document\view.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\element\view-fwd.hpp
del include\bsoncxx\v1\element\view-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\element\view.hpp
del include\bsoncxx\v1\element\view.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\exception-fwd.hpp
del include\bsoncxx\v1\exception-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\exception.hpp
del include\bsoncxx\v1\exception.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\oid-fwd.hpp
del include\bsoncxx\v1\oid-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\oid.hpp
del include\bsoncxx\v1\oid.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\stdx\optional.hpp
del include\bsoncxx\v1\stdx\optional.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\stdx\string_view.hpp
del include\bsoncxx\v1\stdx\string_view.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\types\id-fwd.hpp
del include\bsoncxx\v1\types\id-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\types\id.hpp
del include\bsoncxx\v1\types\id.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\types\value-fwd.hpp
del include\bsoncxx\v1\types\value-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\types\value.hpp
del include\bsoncxx\v1\types\value.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\types\view-fwd.hpp
del include\bsoncxx\v1\types\view-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\types\view.hpp
del include\bsoncxx\v1\types\view.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\array\element-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\array\element-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\array\element.hpp
del include\bsoncxx\v_noabi\bsoncxx\array\element.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\array\value-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\array\value-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\array\value.hpp
del include\bsoncxx\v_noabi\bsoncxx\array\value.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\array\view-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\array\view-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\array\view.hpp
del include\bsoncxx\v_noabi\bsoncxx\array\view.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\array\view_or_value.hpp
del include\bsoncxx\v_noabi\bsoncxx\array\view_or_value.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\basic\array-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\basic\array-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\basic\array.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\basic\array.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\basic\document-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\basic\document-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\basic\document.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\basic\document.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\basic\helpers.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\basic\helpers.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\basic\impl.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\basic\impl.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\basic\kvp.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\basic\kvp.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\basic\sub_array-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\basic\sub_array-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\basic\sub_array.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\basic\sub_array.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\basic\sub_binary-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\basic\sub_binary-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\basic\sub_binary.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\basic\sub_binary.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\basic\sub_document-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\basic\sub_document-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\basic\sub_document.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\basic\sub_document.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\concatenate-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\concatenate-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\concatenate.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\concatenate.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\core-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\core-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\core.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\core.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\list-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\list-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\list.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\list.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\stream\array-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\stream\array-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\stream\array.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\stream\array.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\stream\array_context-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\stream\array_context-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\stream\array_context.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\stream\array_context.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\stream\closed_context-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\stream\closed_context-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\stream\closed_context.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\stream\closed_context.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\stream\document-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\stream\document-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\stream\document.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\stream\document.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\stream\helpers-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\stream\helpers-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\stream\helpers.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\stream\helpers.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\stream\key_context-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\stream\key_context-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\stream\key_context.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\stream\key_context.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\stream\single_context-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\stream\single_context-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\stream\single_context.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\stream\single_context.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\stream\value_context-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\stream\value_context-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\builder\stream\value_context.hpp
del include\bsoncxx\v_noabi\bsoncxx\builder\stream\value_context.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\config\compiler.hpp
del include\bsoncxx\v_noabi\bsoncxx\config\compiler.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\config\export.hpp
del include\bsoncxx\v_noabi\bsoncxx\config\export.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\config\postlude.hpp
del include\bsoncxx\v_noabi\bsoncxx\config\postlude.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\config\prelude.hpp
del include\bsoncxx\v_noabi\bsoncxx\config\prelude.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\config\util.hpp
del include\bsoncxx\v_noabi\bsoncxx\config\util.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\config\version.hpp
del include\bsoncxx\v_noabi\bsoncxx\config\version.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\decimal128-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\decimal128-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\decimal128.hpp
del include\bsoncxx\v_noabi\bsoncxx\decimal128.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\document\element-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\document\element-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\document\element.hpp
del include\bsoncxx\v_noabi\bsoncxx\document\element.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\document\value-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\document\value-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\document\value.hpp
del include\bsoncxx\v_noabi\bsoncxx\document\value.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\document\view-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\document\view-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\document\view.hpp
del include\bsoncxx\v_noabi\bsoncxx\document\view.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\document\view_or_value.hpp
del include\bsoncxx\v_noabi\bsoncxx\document\view_or_value.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\enums\binary_sub_type.hpp
del include\bsoncxx\v_noabi\bsoncxx\enums\binary_sub_type.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\enums\type.hpp
del include\bsoncxx\v_noabi\bsoncxx\enums\type.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\exception\error_code-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\exception\error_code-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\exception\error_code.hpp
del include\bsoncxx\v_noabi\bsoncxx\exception\error_code.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\exception\exception-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\exception\exception-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\exception\exception.hpp
del include\bsoncxx\v_noabi\bsoncxx\exception\exception.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\json-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\json-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\json.hpp
del include\bsoncxx\v_noabi\bsoncxx\json.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\oid-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\oid-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\oid.hpp
del include\bsoncxx\v_noabi\bsoncxx\oid.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\stdx\operators.hpp
del include\bsoncxx\v_noabi\bsoncxx\stdx\operators.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\stdx\optional.hpp
del include\bsoncxx\v_noabi\bsoncxx\stdx\optional.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\stdx\string_view.hpp
del include\bsoncxx\v_noabi\bsoncxx\stdx\string_view.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\stdx\type_traits.hpp
del include\bsoncxx\v_noabi\bsoncxx\stdx\type_traits.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\string\to_string.hpp
del include\bsoncxx\v_noabi\bsoncxx\string\to_string.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\string\view_or_value-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\string\view_or_value-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\string\view_or_value.hpp
del include\bsoncxx\v_noabi\bsoncxx\string\view_or_value.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\types\bson_value\make_value.hpp
del include\bsoncxx\v_noabi\bsoncxx\types\bson_value\make_value.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\types\bson_value\value-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\types\bson_value\value-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\types\bson_value\value.hpp
del include\bsoncxx\v_noabi\bsoncxx\types\bson_value\value.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\types\bson_value\view-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\types\bson_value\view-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\types\bson_value\view.hpp
del include\bsoncxx\v_noabi\bsoncxx\types\bson_value\view.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\types\bson_value\view_or_value.hpp
del include\bsoncxx\v_noabi\bsoncxx\types\bson_value\view_or_value.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\types\id-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\types\id-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\types\id.hpp
del include\bsoncxx\v_noabi\bsoncxx\types\id.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\types\value-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\types\value-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\types\value.hpp
del include\bsoncxx\v_noabi\bsoncxx\types\value.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\types\view-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\types\view-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\types\view.hpp
del include\bsoncxx\v_noabi\bsoncxx\types\view.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\types-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\types-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\types.hpp
del include\bsoncxx\v_noabi\bsoncxx\types.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\validate-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\validate-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\validate.hpp
del include\bsoncxx\v_noabi\bsoncxx\validate.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\vector\accessor-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\vector\accessor-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\vector\accessor.hpp
del include\bsoncxx\v_noabi\bsoncxx\vector\accessor.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\vector\detail-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\vector\detail-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\vector\detail.hpp
del include\bsoncxx\v_noabi\bsoncxx\vector\detail.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\vector\elements-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\vector\elements-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\vector\elements.hpp
del include\bsoncxx\v_noabi\bsoncxx\vector\elements.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\vector\formats-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\vector\formats-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\vector\formats.hpp
del include\bsoncxx\v_noabi\bsoncxx\vector\formats.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\vector\iterators-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\vector\iterators-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\vector\iterators.hpp
del include\bsoncxx\v_noabi\bsoncxx\vector\iterators.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\view_or_value-fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\view_or_value-fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\view_or_value.hpp
del include\bsoncxx\v_noabi\bsoncxx\view_or_value.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\config\config.hpp
del include\bsoncxx\v1\config\config.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\config\version.hpp
del include\bsoncxx\v1\config\version.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\config\config.hpp
del include\bsoncxx\v_noabi\bsoncxx\config\config.hpp || echo ... not removed
echo Removing file include\bsoncxx\v_noabi\bsoncxx\fwd.hpp
del include\bsoncxx\v_noabi\bsoncxx\fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\fwd.hpp
del include\bsoncxx\v1\fwd.hpp || echo ... not removed
echo Removing file include\bsoncxx\v1\config\export.hpp
del include\bsoncxx\v1\config\export.hpp || echo ... not removed
echo Removing file lib\libbsoncxx1-static.a
del lib\libbsoncxx1-static.a || echo ... not removed
echo Removing file lib\cmake\bsoncxx-4.4.1\bsoncxx_targets.cmake
del lib\cmake\bsoncxx-4.4.1\bsoncxx_targets.cmake || echo ... not removed
echo Removing file lib\cmake\bsoncxx-4.4.1\bsoncxx_targets-release.cmake
del lib\cmake\bsoncxx-4.4.1\bsoncxx_targets-release.cmake || echo ... not removed
echo Removing file lib\cmake\bsoncxx-4.4.1\bsoncxxConfigVersion.cmake
del lib\cmake\bsoncxx-4.4.1\bsoncxxConfigVersion.cmake || echo ... not removed
echo Removing file lib\cmake\bsoncxx-4.4.1\bsoncxxConfig.cmake
del lib\cmake\bsoncxx-4.4.1\bsoncxxConfig.cmake || echo ... not removed
echo Removing file lib\pkgconfig\libbsoncxx1-static.pc
del lib\pkgconfig\libbsoncxx1-static.pc || echo ... not removed
echo Removing file include\mongocxx\v1\aggregate_options-fwd.hpp
del include\mongocxx\v1\aggregate_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\aggregate_options.hpp
del include\mongocxx\v1\aggregate_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\apm-fwd.hpp
del include\mongocxx\v1\apm-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\apm.hpp
del include\mongocxx\v1\apm.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\auto_encryption_options-fwd.hpp
del include\mongocxx\v1\auto_encryption_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\auto_encryption_options.hpp
del include\mongocxx\v1\auto_encryption_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\bulk_write-fwd.hpp
del include\mongocxx\v1\bulk_write-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\bulk_write.hpp
del include\mongocxx\v1\bulk_write.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\change_stream-fwd.hpp
del include\mongocxx\v1\change_stream-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\change_stream.hpp
del include\mongocxx\v1\change_stream.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\client-fwd.hpp
del include\mongocxx\v1\client-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\client.hpp
del include\mongocxx\v1\client.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\client_bulk_write-fwd.hpp
del include\mongocxx\v1\client_bulk_write-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\client_bulk_write.hpp
del include\mongocxx\v1\client_bulk_write.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\client_encryption-fwd.hpp
del include\mongocxx\v1\client_encryption-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\client_encryption.hpp
del include\mongocxx\v1\client_encryption.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\client_session-fwd.hpp
del include\mongocxx\v1\client_session-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\client_session.hpp
del include\mongocxx\v1\client_session.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\collection-fwd.hpp
del include\mongocxx\v1\collection-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\collection.hpp
del include\mongocxx\v1\collection.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\count_options-fwd.hpp
del include\mongocxx\v1\count_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\count_options.hpp
del include\mongocxx\v1\count_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\cursor-fwd.hpp
del include\mongocxx\v1\cursor-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\cursor.hpp
del include\mongocxx\v1\cursor.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\database-fwd.hpp
del include\mongocxx\v1\database-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\database.hpp
del include\mongocxx\v1\database.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\data_key_options-fwd.hpp
del include\mongocxx\v1\data_key_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\data_key_options.hpp
del include\mongocxx\v1\data_key_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\delete_many_options-fwd.hpp
del include\mongocxx\v1\delete_many_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\delete_many_options.hpp
del include\mongocxx\v1\delete_many_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\delete_many_result-fwd.hpp
del include\mongocxx\v1\delete_many_result-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\delete_many_result.hpp
del include\mongocxx\v1\delete_many_result.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\delete_one_options-fwd.hpp
del include\mongocxx\v1\delete_one_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\delete_one_options.hpp
del include\mongocxx\v1\delete_one_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\delete_one_result-fwd.hpp
del include\mongocxx\v1\delete_one_result-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\delete_one_result.hpp
del include\mongocxx\v1\delete_one_result.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\detail\macros.hpp
del include\mongocxx\v1\detail\macros.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\detail\postlude.hpp
del include\mongocxx\v1\detail\postlude.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\detail\prelude.hpp
del include\mongocxx\v1\detail\prelude.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\distinct_options-fwd.hpp
del include\mongocxx\v1\distinct_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\distinct_options.hpp
del include\mongocxx\v1\distinct_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\encrypt_options-fwd.hpp
del include\mongocxx\v1\encrypt_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\encrypt_options.hpp
del include\mongocxx\v1\encrypt_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\estimated_document_count_options-fwd.hpp
del include\mongocxx\v1\estimated_document_count_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\estimated_document_count_options.hpp
del include\mongocxx\v1\estimated_document_count_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\command_failed-fwd.hpp
del include\mongocxx\v1\events\command_failed-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\command_failed.hpp
del include\mongocxx\v1\events\command_failed.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\command_started-fwd.hpp
del include\mongocxx\v1\events\command_started-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\command_started.hpp
del include\mongocxx\v1\events\command_started.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\command_succeeded-fwd.hpp
del include\mongocxx\v1\events\command_succeeded-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\command_succeeded.hpp
del include\mongocxx\v1\events\command_succeeded.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\server_closed-fwd.hpp
del include\mongocxx\v1\events\server_closed-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\server_closed.hpp
del include\mongocxx\v1\events\server_closed.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\server_description-fwd.hpp
del include\mongocxx\v1\events\server_description-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\server_description.hpp
del include\mongocxx\v1\events\server_description.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\server_description_changed-fwd.hpp
del include\mongocxx\v1\events\server_description_changed-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\server_description_changed.hpp
del include\mongocxx\v1\events\server_description_changed.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\server_heartbeat_failed-fwd.hpp
del include\mongocxx\v1\events\server_heartbeat_failed-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\server_heartbeat_failed.hpp
del include\mongocxx\v1\events\server_heartbeat_failed.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\server_heartbeat_started-fwd.hpp
del include\mongocxx\v1\events\server_heartbeat_started-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\server_heartbeat_started.hpp
del include\mongocxx\v1\events\server_heartbeat_started.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\server_heartbeat_succeeded-fwd.hpp
del include\mongocxx\v1\events\server_heartbeat_succeeded-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\server_heartbeat_succeeded.hpp
del include\mongocxx\v1\events\server_heartbeat_succeeded.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\server_opening-fwd.hpp
del include\mongocxx\v1\events\server_opening-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\server_opening.hpp
del include\mongocxx\v1\events\server_opening.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\topology_closed-fwd.hpp
del include\mongocxx\v1\events\topology_closed-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\topology_closed.hpp
del include\mongocxx\v1\events\topology_closed.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\topology_description-fwd.hpp
del include\mongocxx\v1\events\topology_description-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\topology_description.hpp
del include\mongocxx\v1\events\topology_description.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\topology_description_changed-fwd.hpp
del include\mongocxx\v1\events\topology_description_changed-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\topology_description_changed.hpp
del include\mongocxx\v1\events\topology_description_changed.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\topology_opening-fwd.hpp
del include\mongocxx\v1\events\topology_opening-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\events\topology_opening.hpp
del include\mongocxx\v1\events\topology_opening.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\exception-fwd.hpp
del include\mongocxx\v1\exception-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\exception.hpp
del include\mongocxx\v1\exception.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\find_one_and_delete_options-fwd.hpp
del include\mongocxx\v1\find_one_and_delete_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\find_one_and_delete_options.hpp
del include\mongocxx\v1\find_one_and_delete_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\find_one_and_replace_options-fwd.hpp
del include\mongocxx\v1\find_one_and_replace_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\find_one_and_replace_options.hpp
del include\mongocxx\v1\find_one_and_replace_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\find_one_and_update_options-fwd.hpp
del include\mongocxx\v1\find_one_and_update_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\find_one_and_update_options.hpp
del include\mongocxx\v1\find_one_and_update_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\find_options-fwd.hpp
del include\mongocxx\v1\find_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\find_options.hpp
del include\mongocxx\v1\find_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\gridfs\bucket-fwd.hpp
del include\mongocxx\v1\gridfs\bucket-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\gridfs\bucket.hpp
del include\mongocxx\v1\gridfs\bucket.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\gridfs\downloader-fwd.hpp
del include\mongocxx\v1\gridfs\downloader-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\gridfs\downloader.hpp
del include\mongocxx\v1\gridfs\downloader.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\gridfs\uploader-fwd.hpp
del include\mongocxx\v1\gridfs\uploader-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\gridfs\uploader.hpp
del include\mongocxx\v1\gridfs\uploader.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\gridfs\upload_options-fwd.hpp
del include\mongocxx\v1\gridfs\upload_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\gridfs\upload_options.hpp
del include\mongocxx\v1\gridfs\upload_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\gridfs\upload_result-fwd.hpp
del include\mongocxx\v1\gridfs\upload_result-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\gridfs\upload_result.hpp
del include\mongocxx\v1\gridfs\upload_result.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\hint-fwd.hpp
del include\mongocxx\v1\hint-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\hint.hpp
del include\mongocxx\v1\hint.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\indexes-fwd.hpp
del include\mongocxx\v1\indexes-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\indexes.hpp
del include\mongocxx\v1\indexes.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\insert_many_options-fwd.hpp
del include\mongocxx\v1\insert_many_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\insert_many_options.hpp
del include\mongocxx\v1\insert_many_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\insert_many_result-fwd.hpp
del include\mongocxx\v1\insert_many_result-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\insert_many_result.hpp
del include\mongocxx\v1\insert_many_result.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\insert_one_options-fwd.hpp
del include\mongocxx\v1\insert_one_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\insert_one_options.hpp
del include\mongocxx\v1\insert_one_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\insert_one_result-fwd.hpp
del include\mongocxx\v1\insert_one_result-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\insert_one_result.hpp
del include\mongocxx\v1\insert_one_result.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\instance-fwd.hpp
del include\mongocxx\v1\instance-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\instance.hpp
del include\mongocxx\v1\instance.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\logger-fwd.hpp
del include\mongocxx\v1\logger-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\logger.hpp
del include\mongocxx\v1\logger.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\oidc_callback.hpp
del include\mongocxx\v1\oidc_callback.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\oidc_callback_params-fwd.hpp
del include\mongocxx\v1\oidc_callback_params-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\oidc_callback_params.hpp
del include\mongocxx\v1\oidc_callback_params.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\oidc_credential-fwd.hpp
del include\mongocxx\v1\oidc_credential-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\oidc_credential.hpp
del include\mongocxx\v1\oidc_credential.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\pipeline-fwd.hpp
del include\mongocxx\v1\pipeline-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\pipeline.hpp
del include\mongocxx\v1\pipeline.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\pool-fwd.hpp
del include\mongocxx\v1\pool-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\pool.hpp
del include\mongocxx\v1\pool.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\range_options-fwd.hpp
del include\mongocxx\v1\range_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\range_options.hpp
del include\mongocxx\v1\range_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\read_concern-fwd.hpp
del include\mongocxx\v1\read_concern-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\read_concern.hpp
del include\mongocxx\v1\read_concern.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\read_preference-fwd.hpp
del include\mongocxx\v1\read_preference-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\read_preference.hpp
del include\mongocxx\v1\read_preference.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\replace_one_options-fwd.hpp
del include\mongocxx\v1\replace_one_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\replace_one_options.hpp
del include\mongocxx\v1\replace_one_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\replace_one_result-fwd.hpp
del include\mongocxx\v1\replace_one_result-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\replace_one_result.hpp
del include\mongocxx\v1\replace_one_result.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\return_document-fwd.hpp
del include\mongocxx\v1\return_document-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\return_document.hpp
del include\mongocxx\v1\return_document.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\rewrap_many_datakey_options-fwd.hpp
del include\mongocxx\v1\rewrap_many_datakey_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\rewrap_many_datakey_options.hpp
del include\mongocxx\v1\rewrap_many_datakey_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\rewrap_many_datakey_result-fwd.hpp
del include\mongocxx\v1\rewrap_many_datakey_result-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\rewrap_many_datakey_result.hpp
del include\mongocxx\v1\rewrap_many_datakey_result.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\search_indexes-fwd.hpp
del include\mongocxx\v1\search_indexes-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\search_indexes.hpp
del include\mongocxx\v1\search_indexes.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\server_api-fwd.hpp
del include\mongocxx\v1\server_api-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\server_api.hpp
del include\mongocxx\v1\server_api.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\server_error-fwd.hpp
del include\mongocxx\v1\server_error-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\server_error.hpp
del include\mongocxx\v1\server_error.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\text_options-fwd.hpp
del include\mongocxx\v1\text_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\text_options.hpp
del include\mongocxx\v1\text_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\tls-fwd.hpp
del include\mongocxx\v1\tls-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\tls.hpp
del include\mongocxx\v1\tls.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\transaction_options-fwd.hpp
del include\mongocxx\v1\transaction_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\transaction_options.hpp
del include\mongocxx\v1\transaction_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\update_many_options-fwd.hpp
del include\mongocxx\v1\update_many_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\update_many_options.hpp
del include\mongocxx\v1\update_many_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\update_many_result-fwd.hpp
del include\mongocxx\v1\update_many_result-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\update_many_result.hpp
del include\mongocxx\v1\update_many_result.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\update_one_options-fwd.hpp
del include\mongocxx\v1\update_one_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\update_one_options.hpp
del include\mongocxx\v1\update_one_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\update_one_result-fwd.hpp
del include\mongocxx\v1\update_one_result-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\update_one_result.hpp
del include\mongocxx\v1\update_one_result.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\uri-fwd.hpp
del include\mongocxx\v1\uri-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\uri.hpp
del include\mongocxx\v1\uri.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\write_concern-fwd.hpp
del include\mongocxx\v1\write_concern-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\write_concern.hpp
del include\mongocxx\v1\write_concern.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\bulk_write-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\bulk_write-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\bulk_write.hpp
del include\mongocxx\v_noabi\mongocxx\bulk_write.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\change_stream-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\change_stream-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\change_stream.hpp
del include\mongocxx\v_noabi\mongocxx\change_stream.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\client-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\client-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\client.hpp
del include\mongocxx\v_noabi\mongocxx\client.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\client_bulk_write-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\client_bulk_write-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\client_bulk_write.hpp
del include\mongocxx\v_noabi\mongocxx\client_bulk_write.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\client_encryption-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\client_encryption-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\client_encryption.hpp
del include\mongocxx\v_noabi\mongocxx\client_encryption.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\client_session-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\client_session-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\client_session.hpp
del include\mongocxx\v_noabi\mongocxx\client_session.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\collection-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\collection-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\collection.hpp
del include\mongocxx\v_noabi\mongocxx\collection.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\config\compiler.hpp
del include\mongocxx\v_noabi\mongocxx\config\compiler.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\config\export.hpp
del include\mongocxx\v_noabi\mongocxx\config\export.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\config\postlude.hpp
del include\mongocxx\v_noabi\mongocxx\config\postlude.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\config\prelude.hpp
del include\mongocxx\v_noabi\mongocxx\config\prelude.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\config\version.hpp
del include\mongocxx\v_noabi\mongocxx\config\version.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\cursor-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\cursor-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\cursor.hpp
del include\mongocxx\v_noabi\mongocxx\cursor.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\database-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\database-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\database.hpp
del include\mongocxx\v_noabi\mongocxx\database.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\command_failed_event-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\events\command_failed_event-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\command_failed_event.hpp
del include\mongocxx\v_noabi\mongocxx\events\command_failed_event.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\command_started_event-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\events\command_started_event-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\command_started_event.hpp
del include\mongocxx\v_noabi\mongocxx\events\command_started_event.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\command_succeeded_event-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\events\command_succeeded_event-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\command_succeeded_event.hpp
del include\mongocxx\v_noabi\mongocxx\events\command_succeeded_event.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\heartbeat_failed_event-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\events\heartbeat_failed_event-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\heartbeat_failed_event.hpp
del include\mongocxx\v_noabi\mongocxx\events\heartbeat_failed_event.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\heartbeat_started_event-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\events\heartbeat_started_event-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\heartbeat_started_event.hpp
del include\mongocxx\v_noabi\mongocxx\events\heartbeat_started_event.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\heartbeat_succeeded_event-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\events\heartbeat_succeeded_event-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\heartbeat_succeeded_event.hpp
del include\mongocxx\v_noabi\mongocxx\events\heartbeat_succeeded_event.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\server_changed_event-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\events\server_changed_event-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\server_changed_event.hpp
del include\mongocxx\v_noabi\mongocxx\events\server_changed_event.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\server_closed_event-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\events\server_closed_event-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\server_closed_event.hpp
del include\mongocxx\v_noabi\mongocxx\events\server_closed_event.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\server_description-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\events\server_description-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\server_description.hpp
del include\mongocxx\v_noabi\mongocxx\events\server_description.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\server_opening_event-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\events\server_opening_event-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\server_opening_event.hpp
del include\mongocxx\v_noabi\mongocxx\events\server_opening_event.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\topology_changed_event-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\events\topology_changed_event-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\topology_changed_event.hpp
del include\mongocxx\v_noabi\mongocxx\events\topology_changed_event.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\topology_closed_event-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\events\topology_closed_event-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\topology_closed_event.hpp
del include\mongocxx\v_noabi\mongocxx\events\topology_closed_event.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\topology_description-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\events\topology_description-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\topology_description.hpp
del include\mongocxx\v_noabi\mongocxx\events\topology_description.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\topology_opening_event-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\events\topology_opening_event-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\events\topology_opening_event.hpp
del include\mongocxx\v_noabi\mongocxx\events\topology_opening_event.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\authentication_exception-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\exception\authentication_exception-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\authentication_exception.hpp
del include\mongocxx\v_noabi\mongocxx\exception\authentication_exception.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\bulk_write_exception-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\exception\bulk_write_exception-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\bulk_write_exception.hpp
del include\mongocxx\v_noabi\mongocxx\exception\bulk_write_exception.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\error_code-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\exception\error_code-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\error_code.hpp
del include\mongocxx\v_noabi\mongocxx\exception\error_code.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\exception-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\exception\exception-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\exception.hpp
del include\mongocxx\v_noabi\mongocxx\exception\exception.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\gridfs_exception-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\exception\gridfs_exception-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\gridfs_exception.hpp
del include\mongocxx\v_noabi\mongocxx\exception\gridfs_exception.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\logic_error-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\exception\logic_error-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\logic_error.hpp
del include\mongocxx\v_noabi\mongocxx\exception\logic_error.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\operation_exception-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\exception\operation_exception-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\operation_exception.hpp
del include\mongocxx\v_noabi\mongocxx\exception\operation_exception.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\query_exception-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\exception\query_exception-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\query_exception.hpp
del include\mongocxx\v_noabi\mongocxx\exception\query_exception.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\server_error_code-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\exception\server_error_code-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\server_error_code.hpp
del include\mongocxx\v_noabi\mongocxx\exception\server_error_code.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\write_exception-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\exception\write_exception-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\exception\write_exception.hpp
del include\mongocxx\v_noabi\mongocxx\exception\write_exception.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\gridfs\bucket-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\gridfs\bucket-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\gridfs\bucket.hpp
del include\mongocxx\v_noabi\mongocxx\gridfs\bucket.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\gridfs\downloader-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\gridfs\downloader-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\gridfs\downloader.hpp
del include\mongocxx\v_noabi\mongocxx\gridfs\downloader.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\gridfs\uploader-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\gridfs\uploader-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\gridfs\uploader.hpp
del include\mongocxx\v_noabi\mongocxx\gridfs\uploader.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\hint-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\hint-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\hint.hpp
del include\mongocxx\v_noabi\mongocxx\hint.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\index_model-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\index_model-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\index_model.hpp
del include\mongocxx\v_noabi\mongocxx\index_model.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\index_view-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\index_view-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\index_view.hpp
del include\mongocxx\v_noabi\mongocxx\index_view.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\instance-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\instance-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\instance.hpp
del include\mongocxx\v_noabi\mongocxx\instance.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\logger-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\logger-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\logger.hpp
del include\mongocxx\v_noabi\mongocxx\logger.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\model\delete_many-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\model\delete_many-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\model\delete_many.hpp
del include\mongocxx\v_noabi\mongocxx\model\delete_many.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\model\delete_one-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\model\delete_one-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\model\delete_one.hpp
del include\mongocxx\v_noabi\mongocxx\model\delete_one.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\model\insert_one-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\model\insert_one-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\model\insert_one.hpp
del include\mongocxx\v_noabi\mongocxx\model\insert_one.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\model\replace_one-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\model\replace_one-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\model\replace_one.hpp
del include\mongocxx\v_noabi\mongocxx\model\replace_one.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\model\update_many-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\model\update_many-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\model\update_many.hpp
del include\mongocxx\v_noabi\mongocxx\model\update_many.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\model\update_one-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\model\update_one-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\model\update_one.hpp
del include\mongocxx\v_noabi\mongocxx\model\update_one.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\model\write-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\model\write-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\model\write.hpp
del include\mongocxx\v_noabi\mongocxx\model\write.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\oidc_callback.hpp
del include\mongocxx\v_noabi\mongocxx\oidc_callback.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\oidc_callback_params-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\oidc_callback_params-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\oidc_callback_params.hpp
del include\mongocxx\v_noabi\mongocxx\oidc_callback_params.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\oidc_credential-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\oidc_credential-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\oidc_credential.hpp
del include\mongocxx\v_noabi\mongocxx\oidc_credential.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\aggregate-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\aggregate-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\aggregate.hpp
del include\mongocxx\v_noabi\mongocxx\options\aggregate.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\apm-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\apm-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\apm.hpp
del include\mongocxx\v_noabi\mongocxx\options\apm.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\auto_encryption-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\auto_encryption-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\auto_encryption.hpp
del include\mongocxx\v_noabi\mongocxx\options\auto_encryption.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\bulk_write-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\bulk_write-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\bulk_write.hpp
del include\mongocxx\v_noabi\mongocxx\options\bulk_write.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\change_stream-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\change_stream-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\change_stream.hpp
del include\mongocxx\v_noabi\mongocxx\options\change_stream.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\client-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\client-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\client.hpp
del include\mongocxx\v_noabi\mongocxx\options\client.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\client_encryption-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\client_encryption-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\client_encryption.hpp
del include\mongocxx\v_noabi\mongocxx\options\client_encryption.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\client_session-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\client_session-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\client_session.hpp
del include\mongocxx\v_noabi\mongocxx\options\client_session.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\count-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\count-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\count.hpp
del include\mongocxx\v_noabi\mongocxx\options\count.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\data_key-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\data_key-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\data_key.hpp
del include\mongocxx\v_noabi\mongocxx\options\data_key.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\delete-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\delete-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\delete.hpp
del include\mongocxx\v_noabi\mongocxx\options\delete.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\distinct-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\distinct-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\distinct.hpp
del include\mongocxx\v_noabi\mongocxx\options\distinct.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\encrypt-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\encrypt-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\encrypt.hpp
del include\mongocxx\v_noabi\mongocxx\options\encrypt.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\estimated_document_count-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\estimated_document_count-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\estimated_document_count.hpp
del include\mongocxx\v_noabi\mongocxx\options\estimated_document_count.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\find-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\find-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\find.hpp
del include\mongocxx\v_noabi\mongocxx\options\find.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\find_one_and_delete-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\find_one_and_delete-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\find_one_and_delete.hpp
del include\mongocxx\v_noabi\mongocxx\options\find_one_and_delete.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\find_one_and_replace-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\find_one_and_replace-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\find_one_and_replace.hpp
del include\mongocxx\v_noabi\mongocxx\options\find_one_and_replace.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\find_one_and_update-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\find_one_and_update-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\find_one_and_update.hpp
del include\mongocxx\v_noabi\mongocxx\options\find_one_and_update.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\find_one_common_options-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\find_one_common_options-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\find_one_common_options.hpp
del include\mongocxx\v_noabi\mongocxx\options\find_one_common_options.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\gridfs\bucket-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\gridfs\bucket-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\gridfs\bucket.hpp
del include\mongocxx\v_noabi\mongocxx\options\gridfs\bucket.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\gridfs\upload-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\gridfs\upload-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\gridfs\upload.hpp
del include\mongocxx\v_noabi\mongocxx\options\gridfs\upload.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\index-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\index-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\index.hpp
del include\mongocxx\v_noabi\mongocxx\options\index.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\index_view-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\index_view-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\index_view.hpp
del include\mongocxx\v_noabi\mongocxx\options\index_view.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\insert-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\insert-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\insert.hpp
del include\mongocxx\v_noabi\mongocxx\options\insert.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\pool-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\pool-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\pool.hpp
del include\mongocxx\v_noabi\mongocxx\options\pool.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\range-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\range-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\range.hpp
del include\mongocxx\v_noabi\mongocxx\options\range.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\replace-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\replace-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\replace.hpp
del include\mongocxx\v_noabi\mongocxx\options\replace.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\rewrap_many_datakey-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\rewrap_many_datakey-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\rewrap_many_datakey.hpp
del include\mongocxx\v_noabi\mongocxx\options\rewrap_many_datakey.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\server_api-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\server_api-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\server_api.hpp
del include\mongocxx\v_noabi\mongocxx\options\server_api.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\ssl.hpp
del include\mongocxx\v_noabi\mongocxx\options\ssl.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\text-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\text-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\text.hpp
del include\mongocxx\v_noabi\mongocxx\options\text.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\tls-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\tls-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\tls.hpp
del include\mongocxx\v_noabi\mongocxx\options\tls.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\transaction-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\transaction-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\transaction.hpp
del include\mongocxx\v_noabi\mongocxx\options\transaction.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\update-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\options\update-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\options\update.hpp
del include\mongocxx\v_noabi\mongocxx\options\update.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\pipeline-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\pipeline-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\pipeline.hpp
del include\mongocxx\v_noabi\mongocxx\pipeline.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\pool-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\pool-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\pool.hpp
del include\mongocxx\v_noabi\mongocxx\pool.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\read_concern-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\read_concern-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\read_concern.hpp
del include\mongocxx\v_noabi\mongocxx\read_concern.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\read_preference-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\read_preference-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\read_preference.hpp
del include\mongocxx\v_noabi\mongocxx\read_preference.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\result\bulk_write-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\result\bulk_write-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\result\bulk_write.hpp
del include\mongocxx\v_noabi\mongocxx\result\bulk_write.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\result\delete-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\result\delete-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\result\delete.hpp
del include\mongocxx\v_noabi\mongocxx\result\delete.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\result\gridfs\upload-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\result\gridfs\upload-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\result\gridfs\upload.hpp
del include\mongocxx\v_noabi\mongocxx\result\gridfs\upload.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\result\insert_many-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\result\insert_many-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\result\insert_many.hpp
del include\mongocxx\v_noabi\mongocxx\result\insert_many.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\result\insert_one-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\result\insert_one-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\result\insert_one.hpp
del include\mongocxx\v_noabi\mongocxx\result\insert_one.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\result\replace_one-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\result\replace_one-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\result\replace_one.hpp
del include\mongocxx\v_noabi\mongocxx\result\replace_one.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\result\rewrap_many_datakey-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\result\rewrap_many_datakey-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\result\rewrap_many_datakey.hpp
del include\mongocxx\v_noabi\mongocxx\result\rewrap_many_datakey.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\result\update-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\result\update-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\result\update.hpp
del include\mongocxx\v_noabi\mongocxx\result\update.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\search_index_model-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\search_index_model-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\search_index_model.hpp
del include\mongocxx\v_noabi\mongocxx\search_index_model.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\search_index_view-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\search_index_view-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\search_index_view.hpp
del include\mongocxx\v_noabi\mongocxx\search_index_view.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\uri-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\uri-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\uri.hpp
del include\mongocxx\v_noabi\mongocxx\uri.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\validation_criteria-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\validation_criteria-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\validation_criteria.hpp
del include\mongocxx\v_noabi\mongocxx\validation_criteria.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\write_concern-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\write_concern-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\write_concern.hpp
del include\mongocxx\v_noabi\mongocxx\write_concern.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\write_type-fwd.hpp
del include\mongocxx\v_noabi\mongocxx\write_type-fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\write_type.hpp
del include\mongocxx\v_noabi\mongocxx\write_type.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\config\config.hpp
del include\mongocxx\v1\config\config.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\config\version.hpp
del include\mongocxx\v1\config\version.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\config\config.hpp
del include\mongocxx\v_noabi\mongocxx\config\config.hpp || echo ... not removed
echo Removing file include\mongocxx\v_noabi\mongocxx\fwd.hpp
del include\mongocxx\v_noabi\mongocxx\fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\fwd.hpp
del include\mongocxx\v1\fwd.hpp || echo ... not removed
echo Removing file include\mongocxx\v1\config\export.hpp
del include\mongocxx\v1\config\export.hpp || echo ... not removed
echo Removing file lib\libmongocxx1-static.a
del lib\libmongocxx1-static.a || echo ... not removed
echo Removing file lib\cmake\mongocxx-4.4.1\mongocxx_targets.cmake
del lib\cmake\mongocxx-4.4.1\mongocxx_targets.cmake || echo ... not removed
echo Removing file lib\cmake\mongocxx-4.4.1\mongocxx_targets-release.cmake
del lib\cmake\mongocxx-4.4.1\mongocxx_targets-release.cmake || echo ... not removed
echo Removing file lib\cmake\mongocxx-4.4.1\mongocxxConfigVersion.cmake
del lib\cmake\mongocxx-4.4.1\mongocxxConfigVersion.cmake || echo ... not removed
echo Removing file lib\cmake\mongocxx-4.4.1\mongocxxConfig.cmake
del lib\cmake\mongocxx-4.4.1\mongocxxConfig.cmake || echo ... not removed
echo Removing file lib\pkgconfig\libmongocxx1-static.pc
del lib\pkgconfig\libmongocxx1-static.pc || echo ... not removed
echo Removing file share\mongo-cxx-driver\LICENSE
del share\mongo-cxx-driver\LICENSE || echo ... not removed
echo Removing file share\mongo-cxx-driver\README.md
del share\mongo-cxx-driver\README.md || echo ... not removed
echo Removing file share\mongo-cxx-driver\THIRD-PARTY-NOTICES
del share\mongo-cxx-driver\THIRD-PARTY-NOTICES || echo ... not removed
echo Removing file share\mongo-cxx-driver\uninstall.cmd
del share\mongo-cxx-driver\uninstall.cmd || echo ... not removed
echo Removing directory include\bsoncxx\v1\array
(rmdir include\bsoncxx\v1\array 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v1\config
(rmdir include\bsoncxx\v1\config 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v1\detail
(rmdir include\bsoncxx\v1\detail 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v1\document
(rmdir include\bsoncxx\v1\document 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v1\element
(rmdir include\bsoncxx\v1\element 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v1\stdx
(rmdir include\bsoncxx\v1\stdx 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v1\types
(rmdir include\bsoncxx\v1\types 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v1
(rmdir include\bsoncxx\v1 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v_noabi\bsoncxx\array
(rmdir include\bsoncxx\v_noabi\bsoncxx\array 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v_noabi\bsoncxx\builder\basic
(rmdir include\bsoncxx\v_noabi\bsoncxx\builder\basic 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v_noabi\bsoncxx\builder\stream
(rmdir include\bsoncxx\v_noabi\bsoncxx\builder\stream 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v_noabi\bsoncxx\builder
(rmdir include\bsoncxx\v_noabi\bsoncxx\builder 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v_noabi\bsoncxx\config
(rmdir include\bsoncxx\v_noabi\bsoncxx\config 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v_noabi\bsoncxx\document
(rmdir include\bsoncxx\v_noabi\bsoncxx\document 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v_noabi\bsoncxx\enums
(rmdir include\bsoncxx\v_noabi\bsoncxx\enums 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v_noabi\bsoncxx\exception
(rmdir include\bsoncxx\v_noabi\bsoncxx\exception 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v_noabi\bsoncxx\stdx
(rmdir include\bsoncxx\v_noabi\bsoncxx\stdx 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v_noabi\bsoncxx\string
(rmdir include\bsoncxx\v_noabi\bsoncxx\string 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v_noabi\bsoncxx\types\bson_value
(rmdir include\bsoncxx\v_noabi\bsoncxx\types\bson_value 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v_noabi\bsoncxx\types
(rmdir include\bsoncxx\v_noabi\bsoncxx\types 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v_noabi\bsoncxx\vector
(rmdir include\bsoncxx\v_noabi\bsoncxx\vector 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v_noabi\bsoncxx
(rmdir include\bsoncxx\v_noabi\bsoncxx 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx\v_noabi
(rmdir include\bsoncxx\v_noabi 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\bsoncxx
(rmdir include\bsoncxx 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\mongocxx\v1\config
(rmdir include\mongocxx\v1\config 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\mongocxx\v1\detail
(rmdir include\mongocxx\v1\detail 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\mongocxx\v1\events
(rmdir include\mongocxx\v1\events 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\mongocxx\v1\gridfs
(rmdir include\mongocxx\v1\gridfs 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\mongocxx\v1
(rmdir include\mongocxx\v1 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\mongocxx\v_noabi\mongocxx\config
(rmdir include\mongocxx\v_noabi\mongocxx\config 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\mongocxx\v_noabi\mongocxx\events
(rmdir include\mongocxx\v_noabi\mongocxx\events 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\mongocxx\v_noabi\mongocxx\exception
(rmdir include\mongocxx\v_noabi\mongocxx\exception 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\mongocxx\v_noabi\mongocxx\gridfs
(rmdir include\mongocxx\v_noabi\mongocxx\gridfs 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\mongocxx\v_noabi\mongocxx\model
(rmdir include\mongocxx\v_noabi\mongocxx\model 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\mongocxx\v_noabi\mongocxx\options\gridfs
(rmdir include\mongocxx\v_noabi\mongocxx\options\gridfs 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\mongocxx\v_noabi\mongocxx\options
(rmdir include\mongocxx\v_noabi\mongocxx\options 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\mongocxx\v_noabi\mongocxx\result\gridfs
(rmdir include\mongocxx\v_noabi\mongocxx\result\gridfs 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\mongocxx\v_noabi\mongocxx\result
(rmdir include\mongocxx\v_noabi\mongocxx\result 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\mongocxx\v_noabi\mongocxx
(rmdir include\mongocxx\v_noabi\mongocxx 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\mongocxx\v_noabi
(rmdir include\mongocxx\v_noabi 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include\mongocxx
(rmdir include\mongocxx 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory include
(rmdir include 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory lib\cmake\bsoncxx-4.4.1
(rmdir lib\cmake\bsoncxx-4.4.1 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory lib\cmake\mongocxx-4.4.1
(rmdir lib\cmake\mongocxx-4.4.1 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory lib\cmake
(rmdir lib\cmake 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory lib\pkgconfig
(rmdir lib\pkgconfig 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory lib
(rmdir lib 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory share\mongo-cxx-driver
(rmdir share\mongo-cxx-driver 2>NUL) || echo ... not removed (probably not empty)
echo Removing directory share
(rmdir share 2>NUL) || echo ... not removed (probably not empty)
cd ..
echo Removing top-level installation directory: D:\gptwork\RubbageChat\third_party\mongo-driver\
(rmdir D:\gptwork\RubbageChat\third_party\mongo-driver\ 2>NUL) || echo ... not removed (probably not empty)

REM Return to the directory from which the program was called
popd
