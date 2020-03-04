use maplit::hashmap;
use rbx_dom_weak::{RbxInstanceProperties, RbxTree, RbxValue};

use crate::bundled_libraries;

static ENTRYPOINT_PATH: &str = "ServerScriptService.TestRunner";

pub struct TestPlaceInput {
    pub source: RbxTree,
    pub dependencies: Option<RbxTree>,
    pub core_script_security: bool,
}

pub struct TestPlace {
    pub tree: RbxTree,
    pub entrypoint_path: &'static str,
}

impl TestPlace {
    pub fn generate(mut input: TestPlaceInput) -> Self {
        let mut tree = RbxTree::new(RbxInstanceProperties {
            name: "Test Place".to_owned(),
            class_name: "DataModel".to_owned(),
            properties: Default::default(),
        });

        let game = tree.get_root_id();

        let replicated_storage = tree.insert_instance(
            RbxInstanceProperties {
                name: "ReplicatedStorage".to_owned(),
                class_name: "ReplicatedStorage".to_owned(),
                properties: Default::default(),
            },
            game,
        );

        let source_root_id = input.source.get_root_id();
        let source_root = input.source.get_instance(source_root_id).unwrap();
        let source_children = source_root.get_children_ids().to_vec();

        for id in source_children {
            let instance = input.source.get_instance_mut(id).unwrap();
            instance.properties.insert(
                "Tags".to_owned(),
                RbxValue::BinaryString {
                    value: b"TestEZTestRoot".to_vec(),
                },
            );

            input
                .source
                .move_instance(id, &mut tree, replicated_storage);
        }

        if let Some(mut dependencies) = input.dependencies {
            let deps_root_id = dependencies.get_root_id();
            let deps_next_child = dependencies
                .get_instance(deps_root_id)
                .unwrap()
                .get_children_ids()[0];

            let deps_children = dependencies
                .get_instance(deps_next_child)
                .unwrap()
                .get_children_ids()
                .to_vec();

            for id in deps_children {
                dependencies.move_instance(id, &mut tree, replicated_storage);
            }
        }

        let server_script_service = tree.insert_instance(
            RbxInstanceProperties {
                name: "ServerScriptService".to_owned(),
                class_name: "ServerScriptService".to_owned(),
                properties: Default::default(),
            },
            game,
        );

        let runner = tree.insert_instance(
            RbxInstanceProperties {
                name: "TestRunner".to_owned(),
                class_name: "Script".to_owned(),
                properties: hashmap! {
                    "Source".to_owned() => RbxValue::String {
                        value: bundled_libraries::test_runner().to_owned()
                    },

                    // If we're trying to run at core script security, disable
                    // the test runner script. It'll be loaded as a core script,
                    // and not disabling it will cause this code to also run at
                    // normal security.
                    "Disabled".to_owned() => RbxValue::Bool {
                        value: input.core_script_security,
                    },
                },
            },
            server_script_service,
        );

        let mut test_framework =
            rbx_xml::from_str_default(bundled_libraries::testez_rbxmx()).unwrap();
        let framework_root = test_framework.get_root_id();
        let framework_children = test_framework
            .get_instance(framework_root)
            .unwrap()
            .get_children_ids()
            .to_vec();

        for id in framework_children {
            test_framework.move_instance(id, &mut tree, runner);
        }

        TestPlace {
            tree,
            entrypoint_path: ENTRYPOINT_PATH,
        }
    }
}
